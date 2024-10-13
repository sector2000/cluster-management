# app-of-apps

## Installation

Run:

```
helm template . --set cluster_name=<cluster name> -s templates/app-of-apps.yaml | oc apply -f-
```
