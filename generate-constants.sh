#!/bin/sh

# this script produces the sql constants for the go module,
# based on the contents of the latest simple-graph release

rm -rf /tmp/sql.zip
rm -rf /tmp/simple-graph-2.1.0
curl -L -o /tmp/sql.zip https://github.com/dpapathanasiou/simple-graph/archive/refs/tags/v2.1.0.zip
unzip -d /tmp /tmp/sql.zip

mkdir -p simplegraph
target=$(echo "simplegraph/constants.go")

echo 'package simplegraph' > $target
echo '\nconst (' >> $target

# sql files: ready for bindings as-is
for file in $(ls /tmp/simple-graph-2.1.0/sql/*.sql)
do
  sql=$(cat $file)
  val=$(basename $file | sed 's/\.sql//;s/[^-]\+/\L\u&/g;s/-//g')
  echo "    $val = \`$sql" >> $target
  echo '`\n' >> $target
done

# template files: need updating to go syntax (https://pkg.go.dev/text/template)
for file in $(ls /tmp/simple-graph-2.1.0/sql/*.template)
do
  sql=$(cat $file | sed 's/{% endif %}/{{ end }}/g;s/{% endfor %}/{{ end }}/g;s/{% if/{{ if/g;s/{% for [a-zA-Z_]\+ in /{{ range /g;s/ %}/ }}/g;s/[^_]\+ }}/\L\u& }}/g;s/_//g;s/[a-zA-Z_]\+ }}/\.\u&/g;s/ }} }}/ }}/g;s/{{ .End }}/{{ end }}/g;s/jsonExtract/json_extract/g;s/jsonTree/json_tree/g;s/{{ .SearchClause }}/{{ . }}/')
  val=$(basename $file | sed 's/\.template/-template/;s/[^-]\+/\L\u&/g;s/-//g')
  echo "    $val = \`$sql" >> $target
  echo '`\n' >> $target
done

echo ')' >> $target
