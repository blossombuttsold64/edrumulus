#!/usr/bin/env python3

#*******************************************************************************
# Copyright (c) 2022-2022
# Author(s): Volker Fischer
#*******************************************************************************
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
#*******************************************************************************

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import matplotlib.patches as mpatches
import serial

# initializations
try:
  ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=0.01)
except:
  ser = [] # in error case "ser" is a list (is checked below)
print('close plot window to quit')
click_point  = (None, None)
sensor1      = np.array(0.933, dtype=complex)
sensor1.imag = 0.75;
sensor2      = np.array(0.5, dtype=complex)
sensor2.imag = 0;
sensor3      = np.array(0.066987, dtype=complex)
sensor3.imag = 0.75;
fig          = plt.figure(tight_layout=True)
gs           = gridspec.GridSpec(1, 1)
ax0          = fig.add_subplot(gs[0])
fignum       = fig.number
plt.ion()
plt.axis('square')


def onclick(event):
  global click_point
  click_point = (event.xdata, event.ydata)


def get_position(r1, r2):
  # code taken from https://github.com/corrados/edrumulus/discussions/70#discussioncomment-4014893
  # created by jstma:
  x0 = sensor1.real
  y0 = sensor1.imag
  x1 = sensor2.real
  y1 = sensor2.imag
  x2 = sensor3.real
  y2 = sensor3.imag

  x0_sq_plus_y0_sq = x0 * x0 + y0 * y0

  a1 = 2 * (x0 - x1)
  b1 = 2 * (y0 - y1)
  c1 = r1 * r1 + x0_sq_plus_y0_sq - x1 * x1 - y1 * y1

  a2 = 2 * (x0 - x2)
  b2 = 2 * (y0 - y2)
  c2 = r2 * r2 + x0_sq_plus_y0_sq - x2 * x2 - y2 * y2

  div1 = a1 * b2 - a2 * b1
  div2 = a2 * b1 - a1 * b2
  d1   = (2 * r1 * b2 - 2 * r2 * b1) / div1
  e1   = (    c1 * b2 -     c2 * b1) / div1
  d2   = (2 * r1 * a2 - 2 * r2 * a1) / div2
  e2   = (    c1 * a2 -     c2 * a1) / div2

  d_e1_x0 = e1 - x0
  d_e2_y0 = e2 - y0
  a       = d1 * d1 + d2 * d2 - 1
  b       = 2 * d_e1_x0 * d1 + 2 * d_e2_y0 * d2
  c       = d_e1_x0 * d_e1_x0 + d_e2_y0 * d_e2_y0

  # two solutions to the quadratic equation
  r_2 = (-b - np.sqrt(b * b - 4 * a * c)) / (2 * a)

  # this solution seems to always be correct
  x = d1 * r_2 + e1
  y = d2 * r_2 + e2
  return x, y


cid = fig.canvas.mpl_connect('button_press_event', onclick)
while True:
  ax0.cla()

  # pad edge boundary circle
  ax0.add_patch(mpatches.Circle((0.5, 0.5), 0.75, fill=False, linewidth=4))
  plt.text(0.44, -0.1, "Drums", weight="bold")

  # sensors
  plt.scatter(sensor1.real, sensor1.imag, marker="x", c="g", s=150)
  plt.scatter(sensor2.real, sensor2.imag, marker="x", c="g", s=150)
  plt.scatter(sensor3.real, sensor3.imag, marker="x", c="g", s=150)

  # create current mouse click vector
  click_vector      = np.array(click_point[0], dtype=complex)
  click_vector.imag = click_point[1];

  l1 = np.abs(click_vector - sensor1)
  l2 = np.abs(click_vector - sensor2)
  l3 = np.abs(click_vector - sensor3)

  l21 = l2 - l1
  l31 = l3 - l1
  l32 = l3 - l2

  # approximation of distance: r = max(|L21|, |L31|, |L32|) (using some magic factor of 0.7)
  r_est = np.max(np.array([np.abs(l21), np.abs(l31), np.abs(l32)])) * 0.7

  # get position algorithm
  x_get, y_get = get_position(l21, l31)

  # show ideal circle (dashed) and circle based on approximation
  ax0.add_patch(mpatches.Circle((0.5, 0.5), np.abs(click_vector - (0.5 + 0.5j)), fill=False, color="b", ls='--'))
  ax0.add_patch(mpatches.Circle((0.5, 0.5), r_est, fill=False, color="b", lw=2))

  # show click point and get position point
  plt.scatter(click_point[0], click_point[1], marker="*", c="r", s=100)
  plt.scatter(x_get, y_get, marker="*", c="g", s=100)

  # for a test return measured differences via a serial string from Edrumulus
  if type(ser) is not list: # check for valid "ser" object
    a = ser.readline().decode("utf-8")
    if len(a) > 0:
      a = a.split(",")[0:3]
      a = [int(x) / 17 for x in a]
      #print(a)
      x, y = get_position(a[0], a[1])
      plt.scatter(x, y, marker="*", c="b", s=700)
      plt.pause(0.05)

  plt.show()
  plt.pause(0.03)
  if not plt.fignum_exists(fignum): # if plot window is closed then quit
    break

