process PURGEDUPS_SPLITFA {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::purge_dups=1.2.6" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/purge_dups:1.2.6--h7132678_0':
        'quay.io/biocontainers/purge_dups:1.2.6--h7132678_0' }"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("*.split.fasta"), emit: split_fasta
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    split_fa $args $assembly > ${prefix}.split.fasta
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        purgedups: \$( purge_dups -h |& sed '3!d; s/.*: //' )
    END_VERSIONS
    """
}
