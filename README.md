# About
Playbook `play__osl_cut_off` automates steps of OSL cut-off process.

Steps
- build the docker image
- run the playbook

# Build the Docker image
```
./build_docker.sh
```

# Run the playbook

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
