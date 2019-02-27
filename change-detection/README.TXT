Readme file for the MATLAB software package accompanying the paper "Long-Term Visual Localization in Dynamic Indoor Environments" by  Erik Derner, Alejandra C. Hernandez, Clara Gomez, Ramon Barber, and Robert Babuska
Personal webpage, including e-mail contact: http://people.ciirc.cvut.cz/derneeri
15 February 2019

Requirements:
- MATLAB R2018b
- Robotics System Toolbox
- TurtleBot Robot Support from Robotics System Toolbox

Description of Matlab scripts:
tbstart - initialize a TurtleBot object 
imgdbRecord - record a sequence of images using TurtleBot
imgRec2imgdb - convert a sequence of images recorded by imgdbRecord to an image database (imgdb structure)
localizationLoop - real-time localization on a TurtleBot
evaluationLoopStatic - localization simulation, where one imgdb structure serves as the database and another one as the sequence of query images; static database, without detection of changes
evaluationLoopDynamic - localization simulation, where one imgdb structure serves as the database and another one as the sequence of query images; updating the image database based on the detected changes
plotTrajectory - plot the trajectory of the TurtleBot recorded in an image database
imgdbViewer - view images in an image database