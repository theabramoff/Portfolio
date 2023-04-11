The structure of the project:
```
.
├── ansible.cfg                                     # ansible config file
├── README.md                                       # project info
├── group_vars                                      # group vars directory
│   ├── all.yml                                     # vars for all hosts (secrets are encrypted)
│   ├── backend.yml                                 # vars for backend hosts     
│   └── frontend.yml                                # vars for backend hosts
├── inventory                                       # inventory directory
│   └── inventory.yaml                              # hosts inventory 
├── playbook.yml                                    # playbook for sausage store installation
└── roles                                           # roles directory - include 2 main roles
    ├── backend                                     # backend roles directory
    │   ├── files                                   # files backend role directory
    │   │   ├── sausage-store-backend.service       # unit
    │   │   └── sudoer_jarservice                   # update sudoers for backend user
    │   └── tasks                                   # backend tasks directory
    │       ├── backend_artifacts_download.yml      # task for download maven artifacts
    │       ├── backend_unit_upload.yml             # task for unit upload
    │       ├── backend_user_create.yml             # task for backend user creation
    │       ├── java_install.yml                    # task for java installation
    │       ├── main.yml                            # consolidation all tasks in main.yml
    │       └── python3-pip_install.yml             # task install python (requires for maven module)
    └── frontend                                    # frontend roles directory
        ├── files                                   # files frontend role directory
        │   ├── sausage-store-frontend.service      # unit
        │   └── sudoer_frontend                     # update sudoers for frontend user
        └── tasks                                   # frontend tasks directory
            ├── frontend_artifacts_download.yml     # task for download raw artifacts and its cleanup after unarchive
            ├── frontend_unit_upload.yml            # task for unit upload
            ├── frontend_user_create.yml            # task for frontend user creation
            ├── main.yml                            # consolidation all tasks in main.yml
            ├── nodejs_install.yml                  # task for nodejs installation
            └── npm_configure.yml                   # task for NPM configuration
```