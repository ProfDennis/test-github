#!/usr/bin/env python
# coding: utf-8

# In[1]:


#Set the input filename
print('Program spectrum')
print('Converts a list of peaks and intensities to a spectrum.')
print('Version 0, 2021-12-05')
print(' ')
print('The input file consists of two columns of numbers.')
print('The first column is the peak frequency.')
print('The second column is the peak absorbance intensity.')
print(' ')

file_in = input("Enter input peaks filename (default filename is peaks.txt):")
if file_in == "":
  file_in="peaks.txt"
print("The input file is: ", end = "")
print(file_in)


# In[20]:


#Set the output filename
print(" ")
file_out = input("Enter output spectrum filename (default filename is spectrum.txt):")
if file_out == "":
  file_out="spectrum.txt"
print("The spectrum will be saved in file: ", end = "")
print(file_out)


# In[21]:


#Read input file into array of frequencies and absorptivities
import numpy as np
all_peaks = np.loadtxt(file_in, dtype=float) 
print(" ")
print("Peak frequencies and absorptivities are read from file.") 
#print(all_peaks.ndim) 
#print(all_peaks.shape) 
#print(all_peaks[1,1])  
#print(type(all_peaks[1,1])) 
#print(all_peaks.size) 
rows, columns = all_peaks.shape
print("Rows = ",rows, end = "")
print(" Columns = ", columns)
#print(all_peaks)


# In[22]:


# Set the upper and lower limits for the energy scale.

# Determine the maximum and minimum peak energy values
pmax=all_peaks[0,0]
#print(pmax)
pmin=all_peaks[0,0]
#print(pmin)
#print(pmax,pmin)
ps=pmax+pmin
#print(ps)
print(" ")
i = 0
for x in all_peaks:
#  print(all_peaks[i,0])
  if all_peaks[i,0] > pmax:
    pmax=all_peaks[i,0]
  if all_peaks[i,0] < pmin:
    pmin=all_peaks[i,0]
  i += 1

#print(pmax)
#print(pmin)

# Set the energy scale 10% wider than the peak scan
# and add a 50 cm-1 expansion on both sides.
sep=pmax-pmin
pmax=pmax+0.05*sep+50
pmin=pmin-0.05*sep-50
# Set pmax and pmin to integer values
nhold=int(pmax)
pmax=float(nhold)
nhold=int(pmin)
pmin=float(nhold)
if pmin < 0.0:
    pmin=0.0
print("Estimated spectrum minimum and maximum values for the full x axis plot are:", pmin, pmax)


# In[31]:


# Set the low end of the scale for the x axis
# Typing return gives the default value x axis start = 400
print(" ")
pmin=input("Enter the desired x axis start value (default start value is 400): ")
if pmin == "":
    pmin=400
print("The x axis start value is set to:", pmin)

# Set the high end of the scale for the x axis
# Typing return gives the default value x axis start = 3300
print(" ")
pmax=input("Enter the desired x axis end value (default end value is 3300): ")
if pmax == "":
    pmax=3300
print("The x axis end value is set to:", pmax)


# In[24]:


# Set the energy step size for the x axis
# Typing return gives the default value step size = 2.0
print(" ")
stepsize=input("Enter the step size for x axis (default step size is 2.0): ")
if stepsize == "":
    stepsize=2.0
print("The x axis step size is:", stepsize)


# In[25]:


# Set the linewidth for the peaks in the spectrum
# Typing return gives the default value width=20.0
print(" ")
width=input("Enter the linewidth for the peaks (default linewidth is 20.0): ")
if width == "":
    width=20.0
print("The peak linewidth is", width)


# In[41]:


# Calculate the spectrum
print(" ")
print(" The following values are written to file",file_out)
f = open(file_out, "w")
pmin=float(pmin)
pmax=float(pmax)
width=float(width)
stepsize=float(stepsize)
energy=pmin
#print(energy, pmax, all_peaks[0,1], width)
print("   Energy  Intensity")
print("   Energy  Intensity", file=f)
while energy <= pmax:
#    print(energy)
#    var=energy-all_peaks[0,0]
#    print(var)
    intensity=0.0
    i = 0
# Calculate the contribution of each peak at x
    for x in all_peaks:        
        var=(energy-float(all_peaks[i,0]))/(width/2.0)
        intensity=intensity+all_peaks[i,1]/(1.0+var*var)
        i += 1
    print(" ", format(energy, '7.2f'), format(intensity, '7.2f'))
    print(" ", format(energy, '7.2f'), format(intensity, '7.2f'), file=f)
#    ener=str(energy)
#    inten=str(intensity)
#    w=ener+" "+inten
#    f.write(w)
    energy=energy+stepsize
f.close()
print(" The values above have been written to file",file_out)
print(" ")
print(" End of program")


# In[ ]:




