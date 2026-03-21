#' @noRd
auto_y_axis <- function(data) {
  min_value <- min(data, na.rm = TRUE)
  max_value <- max(data, na.rm = TRUE)
  if (min_value < 0 && max_value > 0) {
    lemon::scale_y_symmetric(labels = scales::comma)
  } else {
    ggplot2::scale_y_continuous(labels = scales::comma)
  }
}

#' @noRd
auto_x_axis <- function(data) {
  min_value <- min(data, na.rm = TRUE)
  max_value <- max(data, na.rm = TRUE)
  if (min_value < 0 && max_value > 0) {
    lemon::scale_x_symmetric(labels = scales::comma)
  } else {
    ggplot2::scale_x_continuous(labels = scales::comma)
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
get_col_name <- function(col) {
  if (is.null(col)) {
    output <- NULL
  } else {
    col_name <- deparse(col)
    output <- sub(".*\\$", "", col_name)
  }
  return(output)
}

#' @noRd
clean_col_name <- function(str) {
  output <- str |>
    stringr::str_replace_all("_", " ") |>
    stringr::str_to_sentence()
  return(output)
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
      plot.margin = ggplot2::margin(5, 15, 5, 5),
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
      axis.title.y = ggplot2::element_blank(),
      strip.text.x = ggtext::element_textbox_simple(
        hjust = 0, halign = 0, face = "bold"
      ),
      panel.spacing = ggplot2::unit(1.5, "lines")
    )
}
