import sys
import os
import csv
import numpy
import time
import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm
from matplotlib.ticker import MaxNLocator
import itertools

width 	= 360
height 	= 640
matrix 	= numpy.zeros((width, height))
N = 32
threshhold = 0.7
threshhold_3 = 3
threshhold_5 = 5

def filter3(image):
	width, height = numpy.array(image).shape
	copy = numpy.zeros((width, height))
	for i in range(len(image)):
		for j in range(len(image[i])):
			# Top-left corner
			copy[i, j] = image[i, j]
			if image[i, j] == -2.0/N:
				temp3 = list(itertools.product(range(i-1, i+2), range(j-1, j+2)))
				temp3 = filter(lambda x: x[0] > -1 and x[0] < width and x[1] > -1 and x[1] < height, temp3)
				temp3.remove((i, j))

				temp5 = list(itertools.product(range(i-2, i+3), range(j-2, j+3)))
				temp5 = filter(lambda x: x[0] > -1 and x[0] < width and x[1] > -1 and x[1] < height, temp5)
				temp5.remove((i, j))
				for couple in temp3:
					temp5.remove(couple)

				number5 = 0
				number3 = 0
				value = 0
				for x, y in temp3:
					if image[x, y] != -2.0/N:
						number3 += 1
						value += image[x, y]
				for x, y in temp5:
					if image[x, y] != -2.0/N:
						number5 += 1
						value += image[x, y]
				value /= (number5 + number3) if number3+number5>0 else 1
				if number3 > threshhold_3 and number5 > threshhold_5:
					copy[i, j] = value
	return copy

with open(sys.argv[1]) as file:
	rows = csv.reader(file, delimiter=' ')
	for row in rows:
		_, _, depth, j, i, valid = row
		i, j = int(i), int(j)
		matrix[j, i] = float(depth)
		if valid == "0":
			matrix[j, i] = - 2.0 / N
		if float(depth) > threshhold:
			matrix[j, i] = - 1.0 / N

matrix = numpy.fliplr(matrix)
x, y = numpy.mgrid[slice(0, width, 1), slice(0, height, 1)]
levels = MaxNLocator(nbins=N).tick_values(matrix.reshape(-1).min(), matrix.reshape(-1).max())
cmap = plt.get_cmap('Greys')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
#fig, ax = plt.subplots()
#im 		= ax.pcolormesh(x, y, matrix, cmap=cmap, norm=norm)
#cbar 	= fig.colorbar(im, ax=ax)
#cbar.set_label('depth in meter')
#ax.set_title('Depth value in a 2D matrix')
#ax.set_xlabel("i")
#ax.set_ylabel("j")
#plt.show()

fig, ax = plt.subplots()

copy_matrix = filter3(matrix)

im 		= ax.pcolormesh(x, y, copy_matrix, cmap=cmap, norm=norm)
cbar 	= fig.colorbar(im, ax=ax)
cbar.set_label('depth in meter')
ax.set_title('Depth value in a 2D matrix')
ax.set_xlabel("i")
ax.set_ylabel("j")
plt.show()