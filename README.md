# Geophysical Imaging: Seismic Methods and Seismic Waves

This repository contains my Geophysical Imaging homework project on seismic methods and seismic-wave propagation. The work investigates two-dimensional acoustic wave propagation using a finite-difference numerical solver and analyzes how subsurface velocity structure, source design, and receiver geometry influence recorded seismic data. The simulations were carried out with ACU2D_PRO and focus on understanding fundamental wave-physics phenomena through synthetic wavefields and seismograms.

The project includes a sequence of numerical experiments. In the first set of exercises, I studied the effect of changing the source position, receiver geometry, source type, and velocity model. These tests show how acquisition geometry and medium properties affect arrival times, symmetry, and waveform appearance. In particular, the report compares a homogeneous reference case with configurations using a moved source, a linear receiver line, a sinusoidal source, and a two-layer velocity model with reflection and transmission effects.

The second part of the project analyzes wave propagation in layered media and examines trace energy as a function of source–receiver distance. The results illustrate the role of geometric spreading and show how energy decays with offset. Additional experiments investigate plane-wave propagation in a two-layer medium and a focused beamforming configuration in which source time delays are designed to concentrate acoustic energy near a prescribed target point.

A major part of the report is dedicated to seismic refraction analysis. First-arrival times were manually picked from a shot gather, calibrated from image coordinates into physical coordinates, and then analyzed in a time–distance diagram. Linear fits were used to estimate direct-wave and refracted-wave velocities, and the time-intercept method was applied to estimate refractor depth. The report obtained approximate velocities of 1365 m/s and 2643 m/s, with an estimated refractor depth of 84.6 m.

The project also includes two extended applications. One example demonstrates Huygens’ principle by modeling diffraction around a high-velocity rectangular obstacle embedded in a lower-velocity background. Another constructs a heterogeneous velocity model from a grayscale image and simulates wave propagation through that medium, showing distorted wavefronts and scattering effects. In the final exercise, smartphone accelerometer measurements recorded during walking and bus travel were compared, showing that walking produces larger and more irregular accelerations than bus motion.

Overall, this project combines seismic modeling, acquisition analysis, wavefield interpretation, refraction processing, and basic sensor-data analysis. It provides a practical introduction to how seismic waves interact with layered and heterogeneous media and how those effects can be interpreted from synthetic and measured data.


## Author

Zahra Nazar Zadeh Attar
