#' @importFrom rlang .data
#' @noRd
ggauto_density <- function(var1, var2) {
  if (is.null(var2)) {
    p_data <- data.frame(x = var1, y = "")
  } else {
    p_data <- data.frame(x = var2, y = var1)
    if (is.character(p_data$y)) {
      p_data <- p_data |>
        dplyr::mutate(y = stringr::str_wrap(stats::reorder(y, x,
          FUN = stats::median
        ), 20))
    }
  }
  ggplot2::ggplot(
    data = p_data,
    mapping = ggplot2::aes(x = .data$x, y = .data$y)
  ) +
    ggdist::stat_slab(
      fill = khroma::colour("bright")(1)[1],
      scale = 0.5
    ) +
    ggdist::stat_dotsinterval(
      side = "bottom",
      fill = khroma::colour("bright")(1)[1], , scale = 0.5
    ) +
    ggplot2::scale_y_discrete(limits = rev) +
    auto_x_axis(p_data$x)
}

#' @noRd
ggauto_bar <- function(var1, var2) {
  if (is.null(var2)) {
    p_data <- data.frame(x = var1) |>
      dplyr::count(.data$x) |>
      dplyr::rename(Count = .data$n)
  } else {
    p_data <- data.frame(x = var1, Count = var2)
  }
  if (is.character(var1)) {
    p_data <- p_data |>
      dplyr::mutate(x = stringr::str_wrap(
        stats::reorder(.data$x, -.data$Count), 20))
  }
  g <- ggplot2::ggplot(
    data = p_data,
    mapping = ggplot2::aes(x = .data$x, y = .data$Count)
  ) +
    ggplot2::geom_col(fill = khroma::colour("bright")(1)[1]) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::scale_x_discrete(limits = rev) +
    ggplot2::coord_flip(expand = FALSE, clip = "off")
  return(g)
}


#' @noRd
ggauto_scatter <- function(var1, var2, base_size) {
  g <- ggplot2::ggplot(
    data = data.frame(x = var1, y = var2),
    mapping = ggplot2::aes(x = .data$x, y = .data$y)
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_point(size = 0.3 * base_size, alpha = 0.8) +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off") +
    auto_y_axis(var2)
  return(g)
}

#' @noRd
ggauto_scatter_colour <- function(var1, var2, var3, base_size) {
  g <- ggplot2::ggplot(
    data = data.frame(x = var1, y = var2, z = var3),
    mapping = ggplot2::aes(
      x = .data$x, y = .data$y,
      colour = .data$z, shape = .data$z
    )
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_point(size = 0.3 * base_size) +
    khroma::scale_colour_bright() +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off") +
    auto_y_axis(var2)
  return(g)
}

#' @noRd
ggauto_scatter_facet <- function(var1, var2, var3, base_size) {
  n_cat <- length(unique(var3))
  g <- ggplot2::ggplot(
    data = data.frame(x = var1, y = var2, z = var3),
    mapping = ggplot2::aes(
      x = .data$x, y = .data$y,
      colour = .data$z
    )
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_point(size = 0.2 * base_size, show.legend = FALSE) +
    ggplot2::scale_colour_manual(values = rep("black", n_cat)) +
    gghighlight::gghighlight(use_direct_label = FALSE) +
    ggplot2::facet_wrap(~.data$z) +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off") +
    auto_y_axis(var2)
  return(g)
}

#' @noRd
ggauto_line <- function(var1, var2, base_size) {
  g <- ggplot2::ggplot(
    data = data.frame(x = var1, y = var2),
    mapping = ggplot2::aes(x = .data$x, y = .data$y)
  ) +
    auto_zero_line(var2) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::geom_line(linewidth = 0.1 * base_size) +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off")
  return(g)
}

#' @noRd
ggauto_line_colour <- function(var1, var2, var3, base_size) {
  p_data <- data.frame(x = var1, y = var2, z = var3)
  last_date <- p_data |>
    dplyr::group_by(.data$z) |>
    dplyr::slice_max(.data$x)
  g <- ggplot2::ggplot(
    data = p_data,
    mapping = ggplot2::aes(
      x = .data$x, y = .data$y,
      colour = .data$z
    )
  ) +
    auto_zero_line(var2) +
    ggplot2::scale_x_date(expand = expansion(mult = c(0, 0.2))) +
    ggplot2::scale_y_continuous(
      labels = scales::comma,
      expand = expansion(0, 0)
    ) +
    ggplot2::geom_line(
      show.legend = FALSE,
      linewidth = 0.1 * base_size
    ) +
    ggplot2::geom_point(
      data = last_date,
      mapping = ggplot2::aes(shape = .data$z),
      size = 0.3 * base_size
    ) +
    ggrepel::geom_text_repel(
      data = last_date,
      mapping = ggplot2::aes(label = .data$z),
      show.legend = FALSE,
      fontface = "bold",
      direction = "y",
      hjust = 0,
      box.padding = 0.5,
      xlim = c(max(last_date$x), NA),
      seed = 123,
      size = 0.8 * base_size * 0.3528
    ) +
    khroma::scale_colour_bright() +
    ggplot2::coord_cartesian(clip = "off")
  return(g)
}

#' @noRd
ggauto_line_facet <- function(var1, var2, var3, base_size) {
  p_data <- data.frame(x = var1, y = var2, z = var3)
  n_cat <- length(unique(var3))
  g <- ggplot2::ggplot(
    data = p_data,
    mapping = ggplot2::aes(
      x = .data$x, y = .data$y,
      colour = .data$z
    )
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_line(
      show.legend = FALSE,
      linewidth = 0.1 * base_size
    ) +
    ggplot2::scale_colour_manual(values = rep("black", n_cat)) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    gghighlight::gghighlight(use_direct_label = FALSE) +
    ggplot2::facet_wrap(~ .data$z) +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off")
  return(g)
}

#' @noRd
ggauto_heatmap <- function(var1, var2, var3, base_size) {
  if (is.null(var3)) {
    p_data <- data.frame(x = var1, y = var2) |>
      dplyr::count(.data$x, .data$y) |>
      dplyr::mutate(r = scales::rescale(.data$n, to = c(0.1, 0.48)))
  } else {
    p_data <- data.frame(x = var1, y = var2, n = var3) |>
      dplyr::mutate(r = scales::rescale(.data$n, to = c(0.1, 0.48)))
  }
  if (is.character(var1)) {
    p_data <- p_data |>
      dplyr::mutate(x = stringr::str_wrap(
        stats::reorder(.data$x, .data$n,
        FUN = sum
      ), 20))
  }
  if (is.character(var2)) {
    p_data <- p_data |>
      dplyr::mutate(y = stringr::str_wrap(stats::reorder(.data$y, -.data$n,
        FUN = sum
      ), 20))
  }
  label_in_data <- p_data |>
    dplyr::filter(.data$r > 0.24)
  label_out_data <- p_data |>
    dplyr::filter(.data$r <= 0.24)
  g <- ggplot2::ggplot(
    data = p_data
  ) +
    ggforce::geom_circle(
      mapping = ggplot2::aes(
        x0 = .data$x, y0 = .data$y,
        r = .data$r,
        fill = .data$n
      )
    ) +
    ggplot2::scale_x_discrete() +
    ggplot2::scale_y_discrete(limits = rev) +
    ggplot2::coord_fixed(expand = FALSE, clip = "off")
  if (length(unique(var1)) <= 6 && length(unique(var2)) <= 6) {
    g <- g + ggplot2::geom_text(
      data = label_in_data,
      mapping = ggplot2::aes(
        x = .data$x, y = .data$y,
        label = round(.data$n, 2),
        colour = (.data$r) > 0.42
      ),
      size = 1.1 * base_size * 0.3528
    ) +
      ggplot2::geom_text(
        data = label_out_data,
        mapping = ggplot2::aes(
          x = .data$x, y = .data$y,
          label = round(.data$n, 2)
        ),
        nudge_y = -0.28,
        size = 1.1 * base_size * 0.3528
      ) +
      ggplot2::scale_colour_manual(
        values = c("black", "white"),
        guide = "none"
      ) +
      ggplot2::scale_fill_binned(
        palette = "YlGnBu",
        type = "seq",
        guide = "none"
      )
  } else {
    g <- g + ggplot2::scale_fill_binned(
      palette = "YlGnBu",
      type = "seq"
    )
  }
  return(g)
}
