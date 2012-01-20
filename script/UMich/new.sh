
#echo "update investigators set home_department_id=(select id from organizational_units where division_id=$departmentId) where employee_id=$employeeId " >$WORKINGDIRECTORY/updateHomeDept.sql 

awk -F "\t" '{print $13,$7;}' personChanges_10182011.txt | while read empid prognum; do echo "update investigators set home_department_id = (select id from organizational_units where division_id = $prognum ) where employee_id = $empid; " ; done

