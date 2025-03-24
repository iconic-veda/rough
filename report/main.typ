#import "chapters/abstract.typ"
#import "chapters/introduction.typ"
#import "chapters/requirements.typ"
#import "chapters/design.typ"
#import "chapters/implementation.typ"
#import "chapters/results.typ"
#import "chapters/conclusion.typ"


#set text(
    font: "New Computer Modern",
    size: 11.5pt
)

#set page(
    numbering: "i"
)


#page(margin: (x: 0cm, y: 1cm))[
    #grid(
        columns: (2%, 60%),
        rect(fill: red, width: 0.15cm, height: 100%),
        column-gutter: 7em,
        grid.cell[
            #v(10em)
            #set text(size: 12pt)

            #heading("Animagik - Simple Game Engine", outlined: false)
            #v(5em)

            #v(7em)
            #strong[Author(s)] \
            #emph[Cosimo Giraldi, Daniela Viktoria Eberhard, Veda Gupta]// TODO: Add your names here

            #v(25em)
            #strong[Supervisor(s)] \
            #emph[Morgan Konnestad, Jostein Nordengen, Arne-Thomas Aas Søndeled]

            #align(bottom+left)[
              Department of Information and Communication Technology \
              Faculty of Engineering and Science \
              #strong[University of Agder, 2025]
              #v(2em)
            ]
        ]
    )
]

#heading("Preface", outlined: false)

This technical report summarizes the work that has been carried out in the framework of #emph[DAT215 ICT project (Spring 2025)], which is a project-based course with 10 ECTS credits. The project lasted from 01 January 2025 to 30 April 2025. \

No acknowledgement is required.

#pagebreak()

// NOTE: Do we need an abstract?
// #abstract

#pagebreak()

#outline()
#pagebreak()
#outline(title: "List of Figures", target: figure.where(kind: image))
#pagebreak()
#outline(title: "List of Tables", target: figure.where(kind: table))

// NOTE: In the real template there is a blank page here

#set page(
    numbering: "1"
)
#counter(page).update(1)
#set heading(numbering: "1.")

#introduction

#requirements

#design

#implementation

#results

#conclusion


#pagebreak()
#bibliography("works.bib")
