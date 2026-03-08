#' Automatic ggplot plot
#'
#' Automatically create an appropriate ggplot2 chart type based on the
#' classes of the provided variables.
#'
#' @param var1 First variable.
#' @param var2 Optional second variable.
#' @param var3 Optional third variable.
#' @param xlab Label for the x-axis. Defaults to \code{"x"}.
#' @param ylab Label for the y-axis. Defaults to \code{"y"}.
#' @param title Optional plot title.
#' @param subtitle Optional plot subtitle.
#' @param caption Optional plot caption.
#' @param base_size Base font size. Defaults to \code{14}.
#' @param base_family Base font family. Defaults to \code{"sans"}.
#'
#' @return A \code{ggplot2} plot object.
#'
#' @examples
#' ggauto(var1 = mtcars$mpg)
#'
#' @export
ggauto <- function(var1 = NULL, var2 = NULL, var3 = NULL,
                   xlab = "x", ylab = "y",
                   title = NULL, subtitle = NULL, caption = NULL,
                   base_size = 14, base_family = "sans") {
  # One continuous var -> density plot
  if (is.numeric(var1) &&
    is.null(var2) &&
    is.null(var3)) {
    g <- ggauto_density(var1 = var1, var2 = var2)
    ylab <- NULL
  }
  # Two continuous var -> scatter plot
  else if (is.numeric(var1) && is.numeric(var2) && is.null(var3)) {
    g <- ggauto_scatter(var1 = var1, var2 = var2, base_size = base_size)
  }
  # Two continuous var, one discrete var -> coloured scatter plot
  else if (is.numeric(var1) &&
    is.numeric(var2) &&
    (is.character(var3) || is.factor(var3))) {
    if (length(unique(var3)) > 6) {
      stop("You cannot use more than 6 colours.")
    } else {
      g <- ggauto_scatter_colour(
        var1 = var1, var2 = var2,
        var3 = var3, base_size = base_size
      )
    }
  }
  # One date var, one continuous -> line chart
  else if (lubridate::is.Date(var1) &&
    is.numeric(var2) &&
    is.null(var3)) {
    g <- ggauto_line(var1 = var1, var2 = var2, base_size = base_size)
    xlab <- NULL
  }
  # One date var, one continuous var, one discrete var -> coloured line chart
  else if (lubridate::is.Date(var1) &&
    is.numeric(var2) &&
    (is.character(var3) || is.factor(var3))) {
    if (length(unique(var3)) > 6) {
      stop("You cannot use more than 6 colours.")
    } else {
      g <- ggauto_line_colour(
        var1 = var1, var2 = var2, var3 = var3,
        base_size = base_size
      )
      xlab <- NULL
    }
  }
  # One discrete var -> bar plot
  else if ((is.character(var1) || is.factor(var1)) &&
    is.null(var2) &&
    is.null(var3)) {
    g <- ggauto_bar(var1 = var1, var2 = var2)
    ylab <- NULL
  }
  # One discrete var, one continuous -> bar plot / raincloud plot
  else if ((is.character(var1) || is.factor(var1)) &&
    is.numeric(var2) &&
    is.null(var3)) {
    if (max(table(var1)) == 1) {
      g <- ggauto_bar(var1 = var1, var2 = var2)
    } else {
      g <- ggauto_density(var1 = var1, var2 = var2)
    }
    ylab <- NULL
  }
  # Two discrete var -> heatmap plot
  else if ((is.character(var1) || is.factor(var1)) &&
    (is.character(var2) || is.factor(var2)) &&
    is.null(var3)) {
    g <- ggauto_heatmap(var1 = var1, var2 = var2, base_size = base_size)
    xlab <- NULL
    ylab <- NULL
  }

  # Not yet implemented
  else {
    stop("An appropriate chart type has not yet been implemented.")
  }

  # Make title
  new_title <- glue::glue(
    "**{title}**<br><span style='color:#474747; font-size:{0.8*base_size}pt;'>{subtitle}</span>"
  )

  # Edits
  g_final <- g +
    ggplot2::labs(
      x = xlab,
      title = new_title,
      subtitle = ylab,
      caption = caption
    ) +
    theme_auto(base_size = base_size, base_family = base_family)
  return(g_final)
}
