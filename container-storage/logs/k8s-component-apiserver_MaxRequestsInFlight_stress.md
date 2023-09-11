```
i=0
time while [ $i -le 100 ]
do
  ## echo Number: $i $(date)
  kubectl get ns > null
  ((i++))
done
```

```
i=0
time while [ $i -le 100 ]
do
  ## echo Number: $i $(date)
  kubectl get ns > null &
  ## wait
  ((i++))
done
```
