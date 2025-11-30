kubectl -n kube-system patch deploy coredns --type merge -p '{
  "spec": {
    "template": {
      "spec": {
        "nodeSelector": {
          "kubernetes.io/hostname": "master"
        },
        "tolerations": [
          {
            "key": "key1",
            "operator": "Equal",
            "value": "value1",
            "effect": "NoSchedule"
          }
        ]
      }
    }
  }
}'

kubectl -n kube-system patch deploy traefik --type merge -p '{
  "spec": {
    "template": {
      "spec": {
        "nodeSelector": {
          "kubernetes.io/hostname": "master"
        },
        "tolerations": [
          {
            "key": "key1",
            "operator": "Equal",
            "value": "value1",
            "effect": "NoSchedule"
          }
        ]
      }
    }
  }
}'

kubectl -n kube-system patch ds $(kubectl get ds -n kube-system -ojsonpath='{.items[0].metadata.name}') --type merge -p '{
  "spec": {
    "template": {
      "spec": {
        "tolerations": [
          {
            "key": "key1",
            "operator": "Equal",
            "value": "value1",
            "effect": "NoSchedule"
          }
        ]
      }
    }
  }
}'