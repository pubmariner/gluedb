class CsvTransactionsController < ApplicationController

  def show
    @csv_transaction = Protocols::Csv::CsvTransaction.find(params[:id])
  end

end
