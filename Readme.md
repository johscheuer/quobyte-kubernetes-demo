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

$ kubectl -n todo-app get po,svc
NAME                               READY     STATUS    RESTARTS   AGE
po/redis-master-2630570919-zinhv   1/1       Running   0          29s
po/todo-app-3351882929-hu76k       1/1       Running   0          29s
po/todo-app-3351882929-u97j6       1/1       Running   0          29s
po/todo-app-3351882929-wxmj0       1/1       Running   0          29s
NAME               CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
svc/redis-master   10.0.198.67   <none>        6379/TCP   29s
svc/todo-app       10.0.60.96    <none>        80/TCP     29s
NAME              ENDPOINTS                                      AGE
ep/redis-master   10.0.86.6:6379                                 29s
ep/todo-app       10.0.86.5:3000,10.0.94.4:3000,10.0.95.4:3000   29s
```

You can access the Todo app via the following command URL (if you run a local proxy with `kubectl proxy`) <localhost:8001/api/v1/proxy/namespaces/todo-app/services/todo-app>

In the next step we will create some entries for our Todo app:

```bash
$ ./add_entries.sh

# let's read all todos
$ curl -L localhost:8001/api/v1/proxy/namespaces/todo-app/services/todo-app/read/todo
["eat","sleep","code","Quobyte","Kubernetes","Stuff"]
```

### Kill the redis-master

Now we can kill our redis-master which holds all todos:

```bash
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
