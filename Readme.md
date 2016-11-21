# Kubernetes and Quobyte Demo

## Prerequisites

- A running [Kubernetes](https://github.com/kubernetes/kubernetes) Cluster (with at least 2 Nodes)
- A running [Quobyte](https://www.quobyte.com/get-quobyte) Cluster 

## Create a Quobyte Volume

```bash
$ qmgmt -u 138.68.101.22:7860 volume create redis-master root root BASE 0777
```

## Run the example

```bash
$ kubectl create -f todo-app
```

You can access the Todo app via the following command URL (if you run a local proxy with `kubectl proxy`) <localhost:8001/api/v1/proxy/namespaces/todo-app/services/todo-app>

In the next step we will create some entries for our Todo app:

```bash
$ ./add_entries.sh

# let's read all todos
$ curl -L localhost:8001/api/v1/proxy/namespaces/todo-app/services/todo-app/read/todo
```

### Kill the redis-master

Now we can kill our redis-master which holds all todos:

```bash
# Just to ensure our app reads directly from the master
$ kubectl -n todo-app scale --replicas=0 deployment/redis-slave

$ NODE=$(kubectl -n todo-app get po -o jsonpath='{.items[*].status.hostIP}' -l name=redis-master)

# Let's see on which node the mater is running
$ echo ${NODE}

# Drain the Node
$ kubectl drain ${NODE}

# Check on which host the master is now running
$ kubectl -n todo-app get po -o jsonpath='{.items[*].status.hostIP}' -l name=redis-master

# Mark node as scheduleable again
$ kubectl uncordon ${NODE}
```

Let's validate if all todos are still there:

```bash
$ curl -L localhost:8001/api/v1/proxy/namespaces/todo-app/services/todo-app/read/todo
```
