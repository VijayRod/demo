## npm

```
sudo apt update -y && sudo apt install npm -y
node -v; npm -v
```

```
cat << EOF > foo.ts
const anExampleVariable = "Hello World"
console.log(anExampleVariable)
EOF
node foo.ts # Hello World
```

## npm.packate.@kubernetes/client-node

```
cd /tmp
npm install @kubernetes/client-node

:/tmp$ npm ls
tmp@ /tmp
+-- @kubernetes/client-node@0.22.2

ls /tmp/node_modules
```

```
cd /tmp
cat << EOF > foo.ts
const k8s = require('@kubernetes/client-node');

const kc = new k8s.KubeConfig();
kc.loadFromDefault();

const k8sApi = kc.makeApiClient(k8s.CoreV1Api);

const main = async () => {
    try {
        const podsRes = await k8sApi.listNamespacedPod('default');
        console.log(podsRes.body);
    } catch (err) {
        console.error(err);
    }
};

main();
EOF

node foo.ts # install npm # Run it in the same window where you have the working kubectl get ns command
# Or ts-node foo.ts # See the section on typescript

# node foo.ts - here's the output
V1PodList {
  apiVersion: 'v1',
  items: [
    V1Pod {
      apiVersion: undefined,
      kind: undefined,
      metadata: [V1ObjectMeta],
      spec: [V1PodSpec],
      status: [V1PodStatus]
    },
    V1Pod {
      apiVersion: undefined,
      kind: undefined,
      metadata: [V1ObjectMeta],
      spec: [V1PodSpec],
      status: [V1PodStatus]
    },
    V1Pod {
      apiVersion: undefined,
      kind: undefined,
      metadata: [V1ObjectMeta],
      spec: [V1PodSpec],
      status: [V1PodStatus]
    }
  ],
  kind: 'PodList',
  metadata: V1ListMeta {
    _continue: undefined,
    remainingItemCount: undefined,
    resourceVersion: '27495',
    selfLink: undefined
  }
}

k get po
NAME                                READY   STATUS    RESTARTS   AGE
kubeshark-front-75445779f4-pvp2j    1/1     Running   0          107m
kubeshark-hub-6955b99dd4-dfknb      1/1     Running   0          107m
kubeshark-worker-daemon-set-pmns5   2/2     Running   0          107m
```

- https://www.npmjs.com/package/@kubernetes/client-node
- https://github.com/kubernetes-client/javascript
- https://npm.io/package/@kubernetes/client-node
- https://dev.to/turck/tutorial-getting-started-with-kubernetes-clientnode-4l78
