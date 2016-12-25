########## The setup file to compile the model cython code ###########

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext


#Setup script

ext  =  [Extension( "Simulation", 
                   sources=["Simulation.pyx"] )]#, 
#                   extra_compile_args=['-fopenmp'],
#                   extra_link_args=['-fopenmp'] )]

setup(
      name = "Sim_Model", 
      cmdclass={'build_ext' : build_ext},   
      ext_modules=ext
      )
