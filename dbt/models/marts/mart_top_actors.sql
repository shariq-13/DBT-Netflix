{#
    Most prolific actors by number of distinct titles.
    Source is the incremental actor-title model.
#}

with credits as (

    select *
    from {{ ref('int_actor_titles') }}

)

select
    person_id,
    person_name,
    count(*) as title_count

from credits

group by
    person_id,
    person_name

order by title_count desc

limit 100