update investigators set home_department_id = (select id from organizational_units where division_id = home_department_id ) where employee_id = employee_id; 
update investigators set home_department_id = (select id from organizational_units where division_id = 14 ) where employee_id = 61343206; 
update investigators set home_department_id = (select id from organizational_units where division_id = 14 ) where employee_id = 61343206; 
