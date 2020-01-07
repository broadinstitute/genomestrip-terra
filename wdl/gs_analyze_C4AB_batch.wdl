task runAnalysis {
    String genomeBuild
    Array[String] bamPathList
    Array[String] mdPathList
    File? knownKmerFile

    File referenceBundle
    File pipelineBundle
    File resourceBundle

    Float memory
    Int diskSize
    Int numThreads
    Int numPreempt
    Int numRetries
    Boolean requesterPays
    String docker

    String outFileName = "C4_${genomeBuild}.analysis.zip"

    command {
        tar xf ${pipelineBundle} || exit 1
        tar xf ${resourceBundle} || exit 1
        scripts/setup.sh || exit 1
        scripts/setup_requester_pays.sh ${requesterPays} || exit 1
        echo ${sep=' ' bamPathList} | sed 's/ /\n/g' > bampaths.list || exit 1
        echo ${sep=' ' mdPathList} | sed 's/ /\n/g' > mdpaths.list || exit 1
        scripts/retry.sh ${numRetries} scripts/run_C4AB_full_analysis.sh \
            ${genomeBuild} bampaths.list mdpaths.list ${referenceBundle} ${knownKmerFile} || exit 1
    }

    output {
        File outputFile = outFileName
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${diskSize} HDD"
        cpu: "${numThreads}"
        preemptible: "${numPreempt}"
    }
}

workflow gs_analyze_C4AB_batch {
    String genomeBuild
    Array[String] bamPathList
    Array[String] mdPathList
    File? knownKmerFile

    File referenceBundle
    File pipelineBundle = "gs://mccarroll-gs-terra/terra/pipelines.tar.gz"
    File resourceBundle = "gs://mccarroll-gs-terra/terra/package_C4.tar.gz"

    Float memory = 10
    Int diskSize = 30
    Int numThreads = 1
    Int numPreempt
    Int numRetries = 1
    Boolean requesterPays = true
    String docker = "gcr.io/mccarroll-genomestrip/genome-strip:latest"

    call runAnalysis {
        input:
            genomeBuild = genomeBuild,
            bamPathList = bamPathList,
            mdPathList = mdPathList,
            knownKmerFile = knownKmerFile,
            referenceBundle = referenceBundle,
            pipelineBundle = pipelineBundle,
            resourceBundle = resourceBundle,
            memory = memory,
            diskSize = diskSize,
            numThreads = numThreads,
            numPreempt = numPreempt,
            numRetries = numRetries,
            requesterPays = requesterPays,
            docker = docker
    }

    output {
        File outputFile = runAnalysis.outputFile
    }

    meta {
        author: "Bob Handsaker"
        description: "Workflow for custom Genome STRiP analysis of C4, including calling C4 A/B copy number"
    }
}
