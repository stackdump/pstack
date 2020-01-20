from setuptools import setup, find_packages
from os import path
from codecs import open

here = path.abspath(path.dirname(__file__))
with open(path.join(here, 'requirements.txt'), encoding='utf-8') as f:
    requirements = f.read().splitlines()

DESC = """
Listen for json encoded messages from Factomd
and push into the DB
"""

setup(
    name="factom-shovel",
    version="0.1.0",
    author="",
    author_email="",
    description="",
    license='MIT',
    keywords='',
    packages=find_packages(),
    include_package_data=True,
    install_requires=requirements,
    long_description=DESC,
    url="",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Database :: Database Engines/Servers",
        "License :: OSI Approved :: MIT License"
    ],
)
