## README ##
This repository runs the CLF-CBF controller that replicates the work by Vaknin and Idan (2026) on 
"Control Lyapuno and Varrier Functions Based Analytic Controller for Air-breathing Hypersonic Vehicles" and 
generates the plots we used within our final report.

To run the controller for the reference tracking case presented in our report and generate the subsequent plots 
do the following:
1. Run the Startup.m script
2. Run the EvaluateController.m script.

# Folder Structure
- Models: Contains the physics engine
- Controllers: Contains any controller design related work
- CLF: Contains CLF functions
- Plotting: Contains the plotting scripts

# Branches
- main: [DEPRECATED]
- adams-janky-CLF: [DEPRECATED]
- hopes-and-prayers: contains some commented out examples of debugging that was used to try to 
    rectify control instability issues
- presentation-working: Active working branch (new main)

# Controller notes
The CoupledCLF_CBF.m function is the only active controller being used, the other controllers were used for testing.


# Major File Descriptions
- EvaluateController.m:
    Main point of entry for evaluating the CLF and CLF-CBF controllers
- ModelParams.m:
   This is the master source of truth for all configuration artefacts that define the model (both simulation and controller).
- CLF_Test.m:
    Original script used for testing the standalone CLF.
- getLfH.m/getLfg.m
    Gets the lie derivatives with respect to the control barrier function h(x)
- getModelMismatchTerm.m
    Returns the model mismatch term used in the CLF Quadratic program constraint
- Simulation.m
    Runs the physics engine simulation for a provided controller and initial condition.
- getDynamics.m
    Contains the continous time equations of motion and calls to getThrust.m and getAeroCoeffs.m
- getFGDynamics.m
    Does the same thing as getDynamics.m but splits the terms into uncontrollable (F) and controllable (G) terms for use within the lie derivatives.
- OpenLoopControl.m
    "Let aero take the wheel". Used for testing plant model.
- PID.m
    "Output feedback will get you a long way". Also used for testing plant model.
- getRefTraj.m
    Returns the reference trajectory used for the project.
- getLyapP.m
    Calculates P from ARE given error dynamics and Q,R.
- getGammaH.m
    Extended class kappa function on control barrier function.
- extractRleativeWeights.m
    Reverse engineering bryson's rule for original author's tune.
- CoupledCLF_CBF.m
    The meat and potatoes of the problem. This contains both the unconstrained CLF controller and the coupled CLF-CBF controller represented as QP's that get solved using the KKT conditions.
- CBFControl.m
    [DEPRECATED] Original quadprog solution for CBF alone.
- calcCLFControl.m
    [DEPRECATED] Original CLF quadprog solution for CLF alone.
- calcCLFLieDerivs.m
    Calculates the lie derivatives for the CLF.