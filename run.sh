#!/bin/bash

project=${1}
version=${2}
output=${3}
reps=${4}

for i in $(seq ${reps}) ; do
    docker run -it -v $(pwd):/home             cc ./cc-study/build-configs.sh ${project} ${version} ${output}/configs-clean${i}  500
    docker run -it -v $(pwd):/home -e CCACHE=1 cc ./cc-study/build-configs.sh ${project} ${version} ${output}/configs-ccache${i} 500
    docker run -it -v $(pwd):/home             cc ./cc-study/build-commits.sh ${project} ${version} ${output}/commits-clean${i}  500
    docker run -it -v $(pwd):/home -e CCACHE=1 cc ./cc-study/build-commits.sh ${project} ${version} ${output}/commits-ccache${i} 500
done
