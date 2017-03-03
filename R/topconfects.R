

methods::setClass("Topconfects", methods::representation("list"))

methods::setMethod("show", "Topconfects", function(object) {
    cat("$table\n")
    print.data.frame(head(object$table, 10), right=FALSE, row.names=FALSE)
    if (nrow(object$table) > 10) cat("...\n")
    cat(sum(!is.na(object$table$confect)),"of",nrow(object$table),"non-zero", object$effect_desc, "at FDR",object$fdr,"\n")
})

first_match <- function(avail, options, default=NULL) {
    good <- options[options %in% avail]
    if (length(good) == 0) return(default)
    good[1]
}

#' Top confident effect sizes plot
#'
#' @param confects A "Topconfects" class object, as returned from limma_confects, edger_confects, etc.
#'
#' @param n Number if items to show.
#'
#' @return
#'
#' A ggplot2 object. Working non-interactively, you must print() this for it to be displayed.
#'
#' @export
confects_plot <- function(confects, n=50) {
    tab <- confects$table
    mag_col <- first_match(c("logCPM", "AveExpr"), names(tab))

    p <- head(tab, n) %>%
        mutate_(name =~ factor(name,rev(name))) %>%
        ggplot(aes_string(y="name", x="effect")) +
        geom_vline(xintercept=0) +
        geom_segment(aes_string(yend="name", x="confect", xend="effect")) +
        geom_point(aes_string(size=mag_col)) +
        labs(x = confects$effect_desc)

    p
}

#' Mean-expression vs effect size plot
#'
#' Like plotMD in limma, but shows "confect" on the y axis rather than "effect" ("effect" is shown underneath in white). This may be useful for assessing whether effects are only being detected only in highly expressed genes.
#'
#' @param confects A "Topconfects" class object, as returned from limma_confects, edger_confects, etc.
#'
#' @return
#'
#' A ggplot2 object. Working non-interactively, you must print() this for it to be displayed.
#'
#' @export
confects_plot_me <- function(confects) {
    tab <- confects$table
    mag_col <- first_match(c("logCPM", "AveExpr"), names(tab))

    p <- ggplot(tab, aes_string(x=mag_col)) +
        geom_point(aes_string(y="effect"), color="white") +
        geom_hline(yintercept=0) +
        geom_point(data=tab[!is.na(tab$confect),], aes_string(y="confect")) +
        labs(y = confects$effect_desc)

    p
}


#' A plot to compare two rankings
#'
#' This is useful, for example, when comparing different methods of ranking potentially interesting differentially expressed genes.
#'
#' @param vec1 A vector of names.
#'
#' @param vec2 Another vector of names.
#'
#' @param label1 A label to go along with vec1.
#'
#' @param label2 A label to go along with vec2.
#'
#' @param n Show at most the first n names in vec1 and vec2.
#'
#' @return
#'
#' A ggplot2 object. Working non-interactively, you must print() this for it to be displayed.
#'
#' @export
rank_rank_plot <- function(vec1, vec2, label1="First ranking", label2="Second ranking", n=40) {
    vec1 <- head(vec1, n)
    vec2 <- head(vec2, n)

    df1 <- data_frame(rank1=seq_len(length(vec1)), name=vec1)
    df2 <- data_frame(rank2=seq_len(length(vec2)), name=vec2)
    link <- inner_join(df1, df2, "name")
    p <- ggplot(link) +
        geom_segment(aes_string(x="1", xend="2", y="rank1", yend="rank2")) +
        geom_point(aes_string(x="1", y="rank1")) +
        geom_point(aes_string(x="2", y="rank2")) +
        geom_text(data=df1, aes_string(x="0.9",y="rank1",label="name"), hjust=1,vjust=0.5) +
        geom_text(data=df2, aes_string(x="2.1",y="rank2",label="name"), hjust=0,vjust=0.5) +
        scale_x_continuous(limits=c(0,3),breaks=c(1,2), minor_breaks=NULL, labels=c(label1,label2)) +
        scale_y_continuous(breaks=seq_len(n), minor_breaks=NULL, trans="reverse") +
        labs(x="",y="")

    p
}
