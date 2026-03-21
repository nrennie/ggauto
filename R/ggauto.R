#' Automatic ggplot plot
#'
#' Automatically create an appropriate ggplot2 chart type based on the
#' classes of the provided variables.
#'
#' @param var1 First variable. Either vector (for example \code{plot_data$v1}),
#' or quoted character string with a column name (for example \code{"v1"})
#' when passing in data.
#' @param var2 Optional second variable.
#' @param var3 Optional third variable.
#' @param data Optional data frame to get variables from.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis.
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
                   data = NULL,
                   xlab = NULL, ylab = NULL,
                   title = NULL, subtitle = NULL, caption = NULL,
                   base_size = 14, base_family = "sans") {
  # Get data
  if (!is.null(data)) {
    if (!is.null(var1)) {
      var1_name <- var1
      var1 <- data[[var1]]
    }
    if (!is.null(var2)) {
      var2_name <- var2
      var2 <- data[[var2]]
    }
    if (!is.null(var3)) {
      var3_name <- var3
      var3 <- data[[var3]]
    }
  } else {
    var1_name <- get_col_name(substitute(var1))
    var2_name <- get_col_name(substitute(var2))
    var3_name <- get_col_name(substitute(var3))
  }
  # One continuous var -> density plot
  if (is.numeric(var1) &&
    is.null(var2) &&
    is.null(var3)) {
    g <- ggauto_density(var1 = var1, var2 = var2)
    if (is.null(xlab)) {
      xlab <- clean_col_name(var1_name)
    }
    ylab <- NULL
  }
  # Two continuous var -> scatter plot
  else if (is.numeric(var1) && is.numeric(var2) && is.null(var3)) {
    g <- ggauto_scatter(var1 = var1, var2 = var2, base_size = base_size)
    if (is.null(xlab)) {
      xlab <- clean_col_name(var1_name)
    }
    if (is.null(ylab)) {
      ylab <- clean_col_name(var2_name)
    }
  }
  # Two continuous var, one discrete var -> coloured scatter plot
  else if (is.numeric(var1) &&
    is.numeric(var2) &&
    (is.character(var3) || is.factor(var3))) {
    if (length(unique(var3)) > 6) {
      g <- ggauto_scatter_facet(
        var1 = var1, var2 = var2,
        var3 = var3, base_size = base_size
      )
    } else {
      g <- ggauto_scatter_colour(
        var1 = var1, var2 = var2,
        var3 = var3, base_size = base_size
      )
    }
    if (is.null(xlab)) {
      xlab <- clean_col_name(var1_name)
    }
    if (is.null(ylab)) {
      ylab <- clean_col_name(var2_name)
    }
  }
  # One date var, one continuous -> line chart
  else if (lubridate::is.Date(var1) &&
    is.numeric(var2) &&
    is.null(var3)) {
    g <- ggauto_line(var1 = var1, var2 = var2, base_size = base_size)
    if (is.null(ylab)) {
      ylab <- clean_col_name(var2_name)
    }
    xlab <- NULL
  }
  # One date var, one continuous var, one discrete var -> coloured line chart
  else if (lubridate::is.Date(var1) &&
    is.numeric(var2) &&
    (is.character(var3) || is.factor(var3))) {
    if (length(unique(var3)) > 6) {
      g <- ggauto_line_facet(
        var1 = var1, var2 = var2, var3 = var3,
        base_size = base_size
      )
      xlab <- NULL
      if (is.null(ylab)) {
        ylab <- clean_col_name(var2_name)
      }
    } else {
      g <- ggauto_line_colour(
        var1 = var1, var2 = var2, var3 = var3,
        base_size = base_size
      )
      xlab <- NULL
      if (is.null(ylab)) {
        ylab <- clean_col_name(var2_name)
      }
    }
  }
  # One discrete var -> bar plot
  else if ((is.character(var1) || is.factor(var1)) &&
    is.null(var2) &&
    is.null(var3)) {
    g <- ggauto_bar(var1 = var1, var2 = var2)
    ylab <- NULL
    if (is.null(xlab)) {
      xlab <- "Count"
    }
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
    if (is.null(xlab)) {
      xlab <- clean_col_name(var2_name)
    }
    ylab <- NULL
  }
  # Two discrete var -> heatmap plot
  else if ((is.character(var1) || is.factor(var1)) &&
    (is.character(var2) || is.factor(var2)) &&
    is.null(var3)) {
    g <- ggauto_heatmap(
      var1 = var1, var2 = var2, var3 = var3,
      base_size = base_size
    )
    xlab <- NULL
    ylab <- NULL
  }
  # Two discrete var, one continuous -> heatmap plot
  else if ((is.character(var1) || is.factor(var1)) &&
    (is.character(var2) || is.factor(var2)) &&
    is.numeric(var3)) {
    if (max(table(var1, var2)) > 1) {
      stop("Too many values per category. Summarise data first.")
    } else {
      g <- ggauto_heatmap(
        var1 = var1, var2 = var2, var3 = var3,
        base_size = base_size
      )
      xlab <- NULL
      ylab <- NULL
    }
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
