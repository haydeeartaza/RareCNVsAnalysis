# helper functions

# wrap the long titles
wrapper <- function(x, ...)
{
  paste(strwrap(x, ...), collapse = "\n")
}

# Save plot with ggsave
savePlot <- function(filename, plotobj, width, height){
	ggplot2::ggsave(filename=filename, plot=plotobj, width=width, height=height, units="px")
}
