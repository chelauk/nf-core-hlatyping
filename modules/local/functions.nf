/*
 * user defined functions
 */

// Extract fastq names
 def extract_fastq(input_file) {
    Channel.from(input_file)
        .splitCsv(sep : '\t')
        .map { row ->
        def meta    = [:]
        meta.id     = row[0]
        meta.sample = row[1]
        meta.lane     = row[2]
        def file1   = row[3]
        def file2   = row[4]
        [meta, [file1, file2]]
        }
    }

// Check file extension
def has_extension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}
