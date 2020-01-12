CREATE OR REPLACE FUNCTION generate_proof(nonce bigint, capacity bigint[], data bigint[]) RETURNS json
AS $$
    """
    generate random proofs that we know a matrix 'm'
    composed of n vectors length k where n = k
    let d[k] = target data vector of length k
    where n=1, m[0] = d[k]

    and each 
       m[1][k] -> m[n][k]
      are populated w/ non-zero random ints

    generated solution shows that:
      dot(m, soln) = salt

    a salt vector is used to craft a ZKP
      proof =  cross(soln, salt)
    """

    from dbapi import encoding
    import json, time
    from numpy import dot, cross, array, linalg, allclose, frexp
    from numpy.random import randint, seed, shuffle

    def rand_num(cap):
        x = randint(0-cap, cap)
        if x == 0: # no zeros
            return rand_num(cap)
        else:
            return int(x)

    def rand_vector():
        return [  rand_num(cap) for cap in capacity ]

    def vector(scalar):
        return [ scalar for _ in capacity ]

    def proof(secret_nonce=None, salt=None):

        if secret_nonce is None:
            # FIXME secret_nonce seed should be created & stored independently
            secret_nonce = randint(9999)

        # public -----------------------
        seed(nonce)
        if salt is None:
            salt = rand_vector()

        # private ----------------------
        m = [data]
        seed(secret_nonce)

        while len(m) < len(capacity):
            m.append(rand_vector())

        # solve ------------------------
        soln = None
        x = None

        try:
            soln = linalg.solve(m, salt)         # if unsolve-able - raises numpy.linalg.LinAlgError: Singular matrix
            assert allclose(dot(m, soln), salt)  # ensure solution can be used
            x = dot(soln, salt)                  # distil solution into a single float
            assert not allclose(soln, vector(0)) # ensure non-zero proof
            assert not allclose(salt, vector(0)) # ensure non-zero witness
            assert not allclose(x, 0.0)          # no zero solutions allowed
        except Exception as ex:
            raise Exception(
                """%s: priv_seed(%s), pub_seed(%s), solve(%s = %s) => %s, %s"""
                % (ex, secret_nonce, nonce, m, salt, soln, x)
            )

        # proof ------------------------

        # REVIEW: Does this ensure Zero Knowledge?

        # Consider that all parts of matrix 'm' & witness 'w' are random integers
        # (except m[0] which has our non-random data)
        #
        # The Witness is called such b/c it is a party to all oprations
        # effectively 'sees' the source matrix, and retains its shape.
        #
        # NOTE: that floats are generated when creating 's'
        #  - which is the solution to the 'm' = 'w' system of equations
        #
        # The resulting vector collapsed into a single varaible 'x'
        # using dot product s * w = x
        #
        # Value 'x' retains an imprint of the 'shape' and 'magnitude' from 'm' and 'w'
        #
        # using frexp() scales x (2^exponent part of the float is dropped
        # the remaining part called the 'mantissa'
        #   will contains a value bounded by -0.5 -> -0.9, 0.5 -> 0.9
         
        # UPDATE: this matrix combination part of this algorithm is a variation on the hill cypher
        # with some alteration - usually 'w' and 's' represent cleartext and ciphertext
        # this algorithm is slightly different because the key 'm' is generated to contain
        # our target data

        # REVIEW: from testint sofar - this alorithm appears to provide a good 1-way hash
        # provided sufficently random seeds are used to generate nonce values.

        # numpy.frexp() splits x into mantissa (that we keep) and twos exponent (that we throw away)
        mantissa, exponent = array(frexp(x)).tolist()

        return json.dumps({
          'priv': {
              'nonce': secret_nonce, # nonce used to generate secret matrix
              'matrix': array(m).tolist(), # data + secret matrix
              'soln': soln.tolist(), # solves matrix for salt
              'proof': x, # decimal output of dot(soln, salt)
              'frexp': [mantissa, exponent], # decomposed proof
          },
          'pub': {
              'nonce': nonce, # nonce used to generate the witness salt
              'witness': salt, # share the vector we solved for
              'proof': mantissa, # sharing only the scaled value makes it impossible to reverse engineer the matrix
              'hash': encoding.encode(mantissa)
          }
        })

    return proof()

    resource
$$ LANGUAGE plpython3u;

-- test the function
/*
SELECT
  g->'priv'->'matrix'->0 as v_data,
  --g->'priv'->'matrix'->1 as v_random1,
  --g->'priv'->'matrix'->2 as v_random2,
  g->'pub'->'witness' as witness,
  --g->'priv'->'proof' as x_as_decimal,
  --g->'priv'->'frexp'->1 as dropping_twos_exponent_removes_scale,
  g->'priv'->'frexp'->0 as retained_mantissa_proof
FROM
  generate_proof(10, '{10,10,10}','{0,1,0}')  as g;
*/
\x
SELECT g->'priv' as priv, g->'pub' as pub FROM generate_proof(10, '{10,10,10}','{0,1,0}')  as g;
SELECT g->'priv' as priv, g->'pub' as pub FROM generate_proof(10, '{10,10,10,10}','{0,1,0,0}')  as g;
SELECT g->'priv' as priv, g->'pub' as pub FROM generate_proof(10, '{10,10,10,10,10}','{0,1,0,0,0}')  as g;
SELECT g->'priv' as priv, g->'pub' as pub FROM generate_proof(10, '{10,10,10,10,10,10}','{0,1,0,0,0,0}')  as g;
