package=$1

#channel="stable"

default_channel=$(grpcurl -d '{"name":"'${package}'"}' -plaintext localhost:50051 api.Registry.GetPackage | jq -r .defaultChannelName)

cvs=$(grpcurl -d '{"name":"'${package}'"}' -plaintext localhost:50051 api.Registry.GetPackage | jq -r '.channels[]|select(.name == "'${default_channel}'").csvName')

data='{"pkgName": "'${package}'", "channelName": "'${default_channel}'", "csvName": "'${cvs}'"}'

grpcurl -d "$data" -plaintext localhost:50051 api.Registry.GetBundle | jq -r .bundlePath

grpcurl -d "$data" -plaintext localhost:50051 api.Registry.GetBundle | jq -r .csvJson | jq -r .spec.relatedImages[].image



