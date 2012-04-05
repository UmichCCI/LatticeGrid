class CreateInvestigatorLoadDates < ActiveRecord::Migration
  def self.up
    create_table :investigator_load_dates do |t|
      t.timestamp :load_date
    end
    add_index(:investigator_load_dates, [:load_date], :unique => true)
  end

  def self.down
    drop_table :investigator_load_dates
  end
end
