# About
This repository provides a collection of playbooks supporting the automation of the following scenarios within the OSL productization process./

Playbooks
* `play__osl_cut_off` automates steps of OSL cut-off process.
* `play__synchronize_versions_with_pnc_build` automates updates related to kubesmarts/osl-images during the build cycle 

Steps to take:
- build the docker image
- run playbooks

# Build the Docker image
```
./build_docker.sh
```

# Run playbook  - OSL cut-off process

## run from container

make sure that the identity key SSH_KEY_LOCATION provides access to both gitlab and gitlab.cee.redhat.com repositories
```
export CLONE_OUT_HOST=...   # $(mktemp -d)
export SSH_KEY_LOCATION=... # ...
.run_container
```

## run from bare host
Go with default settings (no much usable within a CI)
```
ansible-playbook play__osl_cut_off.yml
```
Go with custom settings while passing a path to variables file  
```
ansible-playbook play__osl_cut_off.yml -e vars_location=release_9.xyz.yml
```

Go with even more custom settings: have control on 
- where to clone related repositories - `cloning_target_dir`
- whether to enable sync+merge with upstream - `sync_with_upstream_enabled`
-  ...
- 
```
ansible-playbook play__osl_cut_off.yml -e vars_location=release_9.xyz.yml -e cloning_target_dir=/some/dir/to/clone
```

# Run playbook  - OSL cut-off process

Scope:
- update versions in operator modules and image definition after PNC build: from "community version" to "productized version" 
- update reference to HEAD of source code of sonataflow-operator

## run from bare host
```
ansible-playbook play__synchronize_versions_with_pnc_build.yml -e kogito_redhat_version=9.105.0.redhat-00002 -e product_version=1.38.0-CR1
```
