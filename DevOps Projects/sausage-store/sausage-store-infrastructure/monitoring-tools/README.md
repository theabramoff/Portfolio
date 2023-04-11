# monitoring

Installing prometheus, grafana, alertmanager
1.  helm upgrade --install prometheus --namespace {{ namespace }} prometheus
2.  helm upgrade --install grafana --namespace {{ namespace }} grafana
3.  helm upgrade --install alertmanager --namespace {{ namespace }} alertmanager

* Grafana password - default
* admin\admin


* URLs for connectivity
* {{ .Release.Namespace }}-monitoring.k8s.praktikum-services.tech - prometheus
* {{ .Release.Namespace }}-grafana.k8s.praktikum-services.tech - grafana
* {{ .Release.Namespace }}-alertmanager.k8s.praktikum-services.tech - alertmanager

Chart structure

```
├── alertmanager
│   ├── Chart.yaml
│   ├── templates
│   │   ├── _helpers.tpl
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   └── services.yaml
│   └── values.yaml
├── grafana
│   ├── Chart.yaml
│   ├── templates
│   │   ├── _helpers.tpl
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── pvc.yaml
│   │   └── services.yaml
│   └── values.yaml
└── prometheus
    ├── Chart.yaml
    ├── prom-app-example.yaml
    ├── rules
    │   └── test.rules
    ├── templates
    │   ├── configmap.yaml
    │   ├── deployment.yaml
    │   ├── ingress.yaml
    │   ├── rules.yaml
    │   └── services.yaml
    └── values.yaml
```