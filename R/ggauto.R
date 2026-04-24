#' Automatic ggplot plot
#'
#' Automatically create an appropriate ggplot2 chart type based on the
#' classes of the provided variables.
#'
#' @param data A data frame, or a bare vector when not using the pipe.
#' @param ... Unquoted column names to plot (e.g. \code{v1, v2}).
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
#' ggauto(mtcars$mpg)
#' mtcars |> ggauto(mpg, wt)
#'
#' @export
ggauto <- function(data = NULL,
                   ...,
                   xlab = NULL, ylab = NULL,
                   title = NULL, subtitle = NULL, caption = NULL,
                   base_size = 14, base_family = "sans") {
  # Check for data
  if (is.null(data) && ...length() == 0) {
    stop("Either `data` or at least one additional argument must be provided.")
  }

  # Capture data
  dots <- rlang::ensyms(...)
  col_names <- lapply(dots, as.character)

  if (is.data.frame(data)) {
    var1 <- if (length(col_names) >= 1) data[[col_names[[1]]]] else NULL
    var2 <- if (length(col_names) >= 2) data[[col_names[[2]]]] else NULL
    var3 <- if (length(col_names) >= 3) data[[col_names[[3]]]] else NULL

    var1_name <- if (length(col_names) >= 1) col_names[[1]] else NULL
    var2_name <- if (length(col_names) >= 2) col_names[[2]] else NULL
    var3_name <- if (length(col_names) >= 3) col_names[[3]] else NULL # nolint
  } else {
    data_expr <- substitute(data)
    all_dots <- c(list(data_expr), lapply(dots, function(d) d))
    var1 <- if (length(all_dots) >= 1) eval(all_dots[[1]], envir = parent.frame()) else NULL
    var2 <- if (length(all_dots) >= 2) eval(all_dots[[2]], envir = parent.frame()) else NULL
    var3 <- if (length(all_dots) >= 3) eval(all_dots[[3]], envir = parent.frame()) else NULL

    get_name <- function(expr) {
      if (is.call(expr) && identical(expr[[1]], as.name("$"))) {
        as.character(expr[[3]]) # right-hand side of $
      } else {
        deparse(expr)
      }
    }

    var1_name <- if (length(all_dots) >= 1) get_name(all_dots[[1]]) else NULL
    var2_name <- if (length(all_dots) >= 2) get_name(all_dots[[2]]) else NULL
    var3_name <- if (length(all_dots) >= 3) get_name(all_dots[[3]]) else NULL
  }

  # One continuous var -> density plot
  if (is.numeric(var1) &&
    is.null(var2) &&
    is.null(var3)) {
    g <- ggauto_density(var1 = var1, var2 = var2)
    if (is.null(xlab)) {
      xlab <- clean_col_name(var1_name)
    }
    if (is.null(ylab)) {
      ylab <- ""
    }
    g <- g +
      theme_auto(base_size = base_size, base_family = base_family)
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
    g <- g +
      theme_auto(base_size = base_size, base_family = base_family)
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
      # Adjust facet height
      lbls <- unique(as.character(var3))
      f_height <- facet_height(lbls)
      g <- g +
        theme_auto(base_size = base_size, base_family = base_family) +
        ggplot2::theme(
          strip.text.x = ggtext::element_textbox_simple(
            hjust = 0, halign = 0, vjust = 0, valign = 0, face = "bold",
            height = NULL,
            minheight = ggplot2::unit(f_height, "lines"),
          )
        )
    } else {
      g <- ggauto_scatter_colour(
        var1 = var1, var2 = var2,
        var3 = var3, base_size = base_size
      )
      g <- g +
        theme_auto(base_size = base_size, base_family = base_family)
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
    if (is.null(xlab)) {
      xlab <- ""
    }
    g <- g +
      theme_auto(base_size = base_size, base_family = base_family)
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
      if (is.null(xlab)) {
        xlab <- ""
      }
      if (is.null(ylab)) {
        ylab <- clean_col_name(var2_name)
      }
      # Adjust facet height
      lbls <- unique(as.character(var3))
      f_height <- facet_height(lbls)
      g <- g +
        theme_auto(base_size = base_size, base_family = base_family) +
        ggplot2::theme(
          strip.text.x = ggtext::element_textbox_simple(
            hjust = 0, halign = 0, vjust = 0, valign = 0, face = "bold",
            height = NULL,
            minheight = ggplot2::unit(f_height, "lines"),
          )
        )
    } else {
      g <- ggauto_line_colour(
        var1 = var1, var2 = var2, var3 = var3,
        base_size = base_size,
        base_family = base_family
      )
      g <- g +
        theme_auto(base_size = base_size, base_family = base_family)
      if (is.null(xlab)) {
        xlab <- ""
      }
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
    if (is.null(xlab)) {
      xlab <- ""
    }
    if (is.null(xlab)) {
      xlab <- "Count"
    }
    g <- g +
      theme_auto(base_size = base_size, base_family = base_family)
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
    if (is.null(ylab)) {
      ylab <- ""
    }
    g <- g +
      theme_auto(base_size = base_size, base_family = base_family)
  }
  # Two discrete var -> heatmap plot
  else if ((is.character(var1) || is.factor(var1)) &&
    (is.character(var2) || is.factor(var2)) &&
    is.null(var3)) {
    g <- ggauto_heatmap(
      var1 = var1, var2 = var2, var3 = var3,
      base_size = base_size
    )
    if (is.null(xlab)) {
      xlab <- ""
    }
    if (is.null(ylab)) {
      ylab <- ""
    }
    g <- g +
      theme_auto(base_size = base_size, base_family = base_family)
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
      if (is.null(xlab)) {
        xlab <- ""
      }
      if (is.null(ylab)) {
        ylab <- ""
      }
      g <- g +
        theme_auto(base_size = base_size, base_family = base_family)
    }
  }

  # Not yet implemented
  else {
    stop("An appropriate chart type has not yet been implemented.")
  }

  # Add text
  new_title <- make_title(title, subtitle, base_size)
  g_final <- g +
    ggplot2::labs(
      x = xlab,
      title = new_title,
      subtitle = ylab,
      caption = caption
    )

  return(g_final)
}
