# Continuous Integration

# VSTS Build Definitions

Each of the subfolders in this repository (`audio`, `categories`, `events`, 
`images`, `proxy`, `text`, and `web`) 
contains a `build` subfolder with a `build.yaml` file. The `build.yaml` 
files contain the list of VSTS build steps that are required for that component.

To use VSTS to continuously build the Content Reactor system, you will need to set up multiple 
build configurations - one for each component with a `build.yaml` file. 
[Follow the instructions here](https://docs.microsoft.com/en-us/vsts/build-release/actions/build-yaml?view=vsts#manually-create-a-yaml-build-definition) 
to create each build definition and select the appropriate `build.yaml` file.

After all the build definitions have been created, queue builds using those definitions

