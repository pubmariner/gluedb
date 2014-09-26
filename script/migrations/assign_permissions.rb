roles = Hash["kevin.wei@dc.gov" => "admin",
  "khalid.mushtaq@dc.gov" => "admin",
  "john.kisor@dc.gov" => "admin",
  "dan.thomas@dc.gov" => "admin",
  "trey.evans@dc.gov" => "admin",
  "ragu.ghanjala@dc.gov" => "admin",
  "saadi.mirza@dc.gov" => "admin",
  "brendan.rose2@dc.gov" => "edi_ops",
  "alison.nelson@dc.gov" => "edi_ops",
  "cherie.smith@dc.gov" => "edi_ops",
  "candice.hammonds@dc.gov" => "edi_ops",
  "zoheb.nensey@dc.gov" => "edi_ops",
  "azizza.brown2@dc.gov" => "edi_ops",
  "pamela.yeung@dc.gov" => "edi_ops",
  "camille.gray@dc.gov" => "edi_ops",
  "selamawit.teka@dc.gov" => "edi_ops",
  "prasanth.manda@dc.gov" => "edi_ops",
  "yvonn.okyere@dc.gov" => "edi_ops",
  "brandon.armani@dc.gov" => "edi_ops",
  "deborah.scott2@dc.gov" => "edi_ops",
  "patricia.faggett@dc.gov" => "edi_ops",
  "johnette.wilson@dc.gov" => "edi_ops",
  "cliff.cooper@dc.gov" => "edi_ops",
  "yogesh.mali@dc.gov" => "edi_ops"]

roles.each do |r|
  u = User.where(email: r[0]).first
  u.role = r[1]
  u.save!
end
