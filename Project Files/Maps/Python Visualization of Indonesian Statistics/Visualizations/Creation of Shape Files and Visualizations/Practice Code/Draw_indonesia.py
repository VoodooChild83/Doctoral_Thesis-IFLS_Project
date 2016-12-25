#Import modules
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from mpl_toolkits.basemap import Basemap
from shapely.geometry import Point, Polygon, MultiPoint, MultiPolygon
from shapely.prepared import prep
import fiona
from matplotlib.collections import PatchCollection
from descartes import PolygonPatch

#Draw a Provinces or Regencies?
flag=raw_input("Draw provinces (enter any number), or regencies (enter any letter), blank to exit: ")

if flag=="": quit()
try:
    test=int(flag)
    #set the directory of the file locations and the parent name of the shape file components
    shapefilename='Province/map'
    #file name of the output image
    file_name='Province_Map'
except:
    #set the directory of the file locations and the parent name of the shape file components
    shapefilename='District/idn_adm2_simplified'
    #file name of the output image
    file_name='District_Map'   

#Get the Bounds
shp = fiona.open(shapefilename+'.shp')
coords = shp.bounds
shp.close()

w, h = coords[2] - coords[0], coords[3] - coords[1]
extra = 0.01

m = Basemap(
    projection='tmerc', ellps='WGS84',
    lon_0=np.mean([coords[0], coords[2]]),
    lat_0=np.mean([coords[1], coords[3]]),
    llcrnrlon=coords[0] - extra * w,
    llcrnrlat=coords[1] - (extra * h), 
    urcrnrlon=coords[2] + extra * w,
    urcrnrlat=coords[3] + (extra * h),
    resolution='i',  suppress_ticks=True, ax=None)

_out = m.readshapefile(shapefilename, name='indonesia', drawbounds=False, color='none', zorder=2)

# set up a map dataframe
df_map = pd.DataFrame({
    'poly': [Polygon(hood_points) for hood_points in m.indonesia],
    #'name': [hood['S_HOOD'] for hood in m.indonesia_info]
})

# Use prep to optimize polygons for faster computation
#hood_polygons = prep(MultiPolygon(list(df_map['poly'].values)))

# Check out the full post at http://beneathdata.com/how-to/visualizing-my-location-history/
# to utilize the code below

# We'll only use a handful of distinct colors for our choropleth. So pick where
# you want your cutoffs to occur. Leave zero and ~infinity alone.
# breaks = [0.] + [4., 24., 64., 135.] + [1e20]
# def self_categorize(entry, breaks):
#     for i in range(len(breaks)-1):
#         if entry > breaks[i] and entry <= breaks[i+1]:
#             return i
#     return -1
#df_map['jenks_bins'] = df_map.hood_hours.apply(self_categorize, args=(breaks,))

#labels = ['Never been\nhere']+["> %d hours"%(perc) for perc in breaks[:-1]]

# Or, you could always use Natural_Breaks to calculate your breaks for you:
# from pysal.esda.mapclassify import Natural_Breaks
# breaks = Natural_Breaks(df_map[df_map['hood_hours'] > 0].hood_hours, initial=300, k=3)
# df_map['jenks_bins'] = -1 #default value if no data exists for this bin
# df_map['jenks_bins'][df_map.hood_count > 0] = breaks.yb
# 
# jenks_labels = ['Never been here', "> 0 hours"]+["> %d hours"%(perc) for perc in breaks.bins[:-1]]

# def custom_colorbar(cmap, ncolors, labels, **kwargs):    
#     """Create a custom, discretized colorbar with correctly formatted/aligned labels.
#     
#     cmap: the matplotlib colormap object you plan on using for your graph
#     ncolors: (int) the number of discrete colors available
#     labels: the list of labels for the colorbar. Should be the same length as ncolors.
#     """
#     from matplotlib.colors import BoundaryNorm
#     from matplotlib.cm import ScalarMappable
#         
#     norm = BoundaryNorm(range(0, ncolors), cmap.N)
#     mappable = ScalarMappable(cmap=cmap, norm=norm)
#     mappable.set_array([])
#     mappable.set_clim(-0.5, ncolors+0.5)
#     colorbar = plt.colorbar(mappable, **kwargs)
#     colorbar.set_ticks(np.linspace(0, ncolors, ncolors+1)+0.5)
#     colorbar.set_ticklabels(range(0, ncolors))
#     colorbar.set_ticklabels(labels)
#     return colorbar

figwidth = 14
fig = plt.figure(figsize=(figwidth, figwidth*h/w))
ax = fig.add_subplot(111, axisbg='w', frame_on=False)

#cmap = plt.get_cmap('Greys')
# draw neighborhoods with grey outlines
df_map['patches'] = df_map['poly'].map(lambda x: PolygonPatch(x, fc='white', ec='#111111', lw=.2, alpha=1., zorder=4))
pc = PatchCollection(df_map['patches'], match_original=True)
# apply our custom color values onto the patch collection
# cmap_list = [cmap(val) for val in (df_map.jenks_bins.values - df_map.jenks_bins.values.min())/(
#                   df_map.jenks_bins.values.max()-float(df_map.jenks_bins.values.min()))]
#pc.set_facecolor(cmap_list)
ax.add_collection(pc)

#Draw a map scale
m.drawmapscale((coords[0] + 5), coords[1],
    coords[0], coords[1], 1000.,
    fontsize=16, barstyle='fancy', labelstyle='simple',
    fillcolor1='w', fillcolor2='#555555', fontcolor='#555555',
    zorder=5)

# ncolors+1 because we're using a "zero-th" color
# cbar = custom_colorbar(cmap, ncolors=len(jenks_labels)+1, labels=jenks_labels, shrink=0.5)
# cbar.ax.tick_params(labelsize=16)

# fig.suptitle("Time Spent in Seattle Neighborhoods", fontdict={'size':24, 'fontweight':'bold'}, y=0.92)
# ax.set_title("Using location data collected from my Android phone via Google Takeout", fontsize=14, y=0.98)
#qax.text(1.35, 0.04, "Collected from 2012-2014 on Android 4.2-4.4\nGeographic data provided by data.seattle.gov", 
#     ha='right', color='#555555', style='italic', transform=ax.transAxes)
# ax.text(1.35, 0.01, "BeneathData.com", color='#555555', fontsize=16, ha='right', transform=ax.transAxes)

plt.savefig(file_name+'.png', dpi=1000, frameon=False, bbox_inches='tight', pad_inches=0.5, facecolor='#F2F2F2')