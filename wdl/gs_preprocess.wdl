task preprocess {
    File bamFile
    File bamIndex
    String referenceBundle

    String docker
    Float memory
    Int numPreempt

    Int diskSize = round(size(bamFile, "G")) + 30

    command {
        $SV_DIR/scripts/terra/gs_preprocess.sh ${bamFile} ${referenceBundle}
    }
    
    output {
        File mdPath = "metadata.zip"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${diskSize} HDD"
        preemptible: "${numPreempt}"
    }
}

workflow gs_preprocessing_wf {
    call preprocess

    meta {
        author: "Bob Handsaker"
        description: "Workflow for standard Genome STRiP preprocessing"
    }
}
