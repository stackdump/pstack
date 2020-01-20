from setuptools import setup, find_packages
from os import path
from codecs import open

setup(
    name="pstack",
    version="0.1.0",
    author="Matthew York",
    author_email="myork@stackdump.com",
    description="",
    license='MIT',
    keywords='pflow pnml petri-net petri petrinet statemachine statevector eventstore Factom PegNet',
    packages=find_packages(),
    include_package_data=True,
    install_requires=["factom-api", "py-factom-did"],
    long_description="""
    """,
    url="",
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Topic :: Database :: Database Engines/Servers",
        "License :: OSI Approved :: MIT License"
    ],
)
