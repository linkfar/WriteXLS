###############################################################################
#
# WriteXLS.R
#
# Write R data frames to an Excel binary file using a Perl script
#
# Copyright 2009, Marc Schwartz <marc_schwartz@me.com>
#
# This software is distributed under the terms of the GNU General
# Public License Version 2, June 1991.  



WriteXLS <- function(x, ExcelFileName = "R.xls", perl = "perl")
{
  # Check to be sure that each 'x' is a data frame
  if (!all(sapply(x, function(i) is.data.frame(get(as.character(i))))))
    stop("One or more of the objects named in 'x' is not a data frame or does not exist")
  
  # Get path to WriteXLS.pl
  Perl.Path <- file.path(.path.package("WriteXLS"), "Perl")
  Fn.Path <- file.path(Perl.Path, "WriteXLS.pl")

  # Get path for Tmp.Dir for CSV files
  Tmp.Dir <- file.path(tempdir(), "WriteXLS")

  # Remove Tmp.Dir and Files
  clean.up <- function()
  {
    cat("Cleaning Up Temporary Files and Directory\n\n")
    unlink(Tmp.Dir, recursive = TRUE)
  }

  # Clean up on function exit
  on.exit(clean.up())

  # Cleanup now, in case Tmp.Dir still exists from a prior run
  if (file.exists(Tmp.Dir))
  {
    cat("Cleaning Up Temporary Files and Directory From Prior Run\n\n")
    unlink(Tmp.Dir, recursive = TRUE)
  }

  # Create Tmp.Dir for new run
  cat("Creating Temporary Directory for CSV Files: ", Tmp.Dir, "\n\n")
  dir.create(Tmp.Dir, recursive = TRUE)

  #  Write Comma Delimited CSV files
  for (i in as.character(x))
  {
    cat("Creating CSV File: ", i, "\n")
    write.table(get(i), file = paste(Tmp.Dir, "/", i, ".csv", sep = ""),
                sep = ",", quote = TRUE, na = "", row.names = FALSE)
  }

  cat("\n")

  # Call Perl script
  cmd <- paste(perl, " -I", Perl.Path, " ", Fn.Path, " --CSVPath ", Tmp.Dir, " ", ExcelFileName, sep = "")
  system(cmd)
}
