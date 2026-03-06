#' @noRd
auto_y_axis <- function(data) {
  min_value <- min(data, na.rm = TRUE)
  max_value <- max(data, na.rm = TRUE)
  if (min_value < 0 && max_value > 0) {
    lemon::scale_y_symmetric()
  } else {
    ggplot2::scale_y_continuous()
  }
}

#' @noRd
auto_x_axis <- function(data) {
  min_value <- min(data, na.rm = TRUE)
  max_value <- max(data, na.rm = TRUE)
  if (min_value < 0 && max_value > 0) {
    lemon::scale_x_symmetric()
  } else {
    ggplot2::scale_x_continuous()
  }
}

#' @noRd
auto_zero_line <- function(data) {
  min_value <- min(data, na.rm = TRUE)
  max_value <- max(data, na.rm = TRUE)
  if (min_value <= 0 && max_value >= 0) {
    ggplot2::geom_hline(
      yintercept = 0, colour = "grey",
      linewidth = 0.8
    )
  }
}

#' @noRd
theme_auto <- function(base_size = 14, base_family = "sans") {
  ggplot2::theme_minimal(base_family = base_family, base_size = base_size) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggtext::element_textbox_simple(
        margin = ggplot2::margin(b = 5),
        lineheight = 0.9
      ),
      plot.subtitle = ggtext::element_textbox_simple(
        colour = "grey50",
        hjust = 0, halign = 0
      ),
      plot.caption = ggtext::element_textbox_simple(
        hjust = 0, halign = 0, colour = "grey50"
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = ggplot2::margin(5, 10, 5, 5),
      plot.background = ggplot2::element_rect(
        fill = "white", colour = "white"
      ),
      axis.title.x = ggplot2::element_text(
        hjust = 1, margin = ggplot2::margin(t = 5),
        colour = "grey50"
      ),
      axis.text.y = ggplot2::element_text(
        size = ggplot2::rel(1)
      ),
      axis.title.y = ggplot2::element_blank()
    )
}
