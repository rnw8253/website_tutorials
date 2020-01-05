import numpy as np                  
from emus import usutils as uu
from emus import emus, avar
import matplotlib.pyplot as plt
np.set_printoptions(threshold=np.inf)

# Define Simulation Parameters
T = 298                             # Temperature in Kelvin
k_B = 1.9872041E-3                  # Boltzmann factor in kcal/mol
kT = k_B * T                        # Temperature in kcal/mol
meta_file = 'metadata.dat'          # Path to Meta File
dim = 1                             # 1 Dimensional CV space.
#period = 360                       # Dihedral Angles periodicity
#domain = ((-180.0,180.))           # Range of dihedral angle values
domain = ((3.0,30.0))               # Range of distance angle values
nbins = 200                         # Number of Histogram Bins.

# Load data
#psis, cv_trajs, neighbors = uu.data_from_meta(meta_file,dim,T=T,k_B=k_B,period=period)
psis, cv_trajs, neighbors = uu.data_from_meta(meta_file,dim,T=T,k_B=k_B)
#psis, cv_trajs, neighbors = emus.usutils.data_from_meta(meta_file,dim,T=T,k_B=k_B)

# Calculate the partition function for each window
z, F = emus.calculate_zs(psis,neighbors=neighbors)

# Calculate error in each z value from the first iteration.
zerr, zcontribs, ztaus  = avar.calc_partition_functions(psis,z,F,iat_method='acor')

# Calculate the PMF from EMUS
pmf,edges = emus.calculate_pmf(cv_trajs,psis,domain,z,nbins=nbins,kT=kT,use_iter=False)   # Calculate the pmf

# Get the asymptotic error of each histogram bin.
pmf_av_mns, pmf_avars = avar.calc_pmf(cv_trajs,psis,domain,z,F,nbins=nbins,kT=kT,iat_method=np.average(ztaus,axis=0))

### Data Output Section ###

# Plot the EMUS, Iterative EMUS pmfs.
pmf_centers = (edges[0][1:]+edges[0][:-1])/2.


# volume correct
for i in range(len(pmf_av_mns)):
    pmf_av_mns[i] += 1.2*np.log(pmf_centers[i])

# Write data to output files
out=open("pmf.dat",'w')
out2=open("c_vals.dat",'w')
for i in range(len(pmf_centers)):
    out.write("  %10.5f  %10.5f  %10.5f\n" %(pmf_centers[i], pmf_av_mns[i], np.sqrt(pmf_avars[i]))) 
out.close
for i in range(len(z_iter_1)):
    out2.write("  %10.5f  %10.10f\n" %(-np.log(z_iter_1[i])*kT,kT*zerr[i]/z_iter_1[i]))
out2.close
