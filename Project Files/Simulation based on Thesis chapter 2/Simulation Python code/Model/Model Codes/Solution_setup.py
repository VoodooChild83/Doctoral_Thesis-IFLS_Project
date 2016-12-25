########## The setup file to compile the model cython code ###########

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

#Setup script

ext  =  [Extension( "Solution", 
                   sources=["Solution.pyx"] )]

setup(
      name = "Modelo", 
      cmdclass={'build_ext' : build_ext}, 
      ext_modules=ext
      )
