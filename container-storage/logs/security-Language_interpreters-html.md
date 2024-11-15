## html

- https://www.w3schools.com/html/default.asp
- https://www.w3schools.com/tags/default.asp
- https://developer.mozilla.org/en-US/docs/Web/HTML

## html.{#each ...}

```
# tablevalues has the table data

<table>
<tr>
<th>Id</th>
<th>Date</th>
{{#each tablevalues}}
<tr>
<td>{{this.Id}}</td>
<td>{{this.Date}}</td>    
</tr>
{{/each}}
</table>
```

- https://svelte.dev/docs/svelte/each
- https://sveltekit.io/blog/svelte-each-blocks
- https://stackoverflow.com/questions/21814888/access-values-using-each-in-a-one-dimensional-array
