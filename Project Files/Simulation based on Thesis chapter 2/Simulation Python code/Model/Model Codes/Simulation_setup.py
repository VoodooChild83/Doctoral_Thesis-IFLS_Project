########## The setup file to compile the simulation cython code ###########

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import cython_gsl


#Setup script

ext  =  [Extension( "Simulation", 
                   sources=["Simulation.pyx"], 
                   extra_compile_args=['-fopenmp'],
                   extra_link_args=['-fopenmp'],
                   libraries=cython_gsl.get_libraries(),
                   library_dirs=[cython_gsl.get_library_dir()],
                   include_dirs=[cython_gsl.get_cython_include_dir()] ) ]

setup(
      name = "Sim_Model", 
      include_dirs = [cython_gsl.get_include()],
      cmdclass={'build_ext' : build_ext},   
      ext_modules=ext
      )
