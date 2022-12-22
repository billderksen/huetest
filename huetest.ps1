# Import the required libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Get the Hue bridge IP address and API key from the user
$bridgeIP = Read-Host 'Enter the IP address of your Hue bridge'
$apiKey = Read-Host 'Enter the API key for your Hue bridge'

# Get a list of all the lights on the Hue bridge
$lights = (Invoke-WebRequest -Uri "http://$bridgeIP/api/$apiKey/lights").Content | ConvertFrom-Json

# Create a new form for the GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Hue Light Control'
$form.Size = New-Object System.Drawing.Size(300,400)
$form.StartPosition = 'CenterScreen'

# Create a checkbox for each light
foreach($light in $lights.Keys)
{
  $checkBox = New-Object System.Windows.Forms.CheckBox
  $checkBox.Text = $light
  $checkBox.AutoSize = $true
  $checkBox.Location = New-Object System.Drawing.Point(10,10+($checkBox.Height+5)*$lights.Keys.IndexOf($light))
  $form.Controls.Add($checkBox)
}

# Create a button to turn all the lights on or off
$button = New-Object System.Windows.Forms.Button
$button.Text = 'Toggle All Lights'
$button.Size = New-Object System.Drawing.Size(100,30)
$button.Location = New-Object System.Drawing.Point(10,10+($checkBox.Height+5)*$lights.Count)
$button.Add_Click({
  foreach($checkBox in $form.Controls | Where-Object {$_.GetType().Name -eq 'CheckBox'})
  {
    # Toggle the state of the light
    $state = (Invoke-WebRequest -Uri "http://$bridgeIP/api/$apiKey/lights/$($checkBox.Text)/state").Content | ConvertFrom-Json
    $state.on = !$state.on
    Invoke-WebRequest -Method Put -Uri "http://$bridgeIP/api/$apiKey/lights/$($checkBox.Text)/state" -Body (ConvertTo-Json $state)
    $checkBox.Checked = $state.on
  }
})
$form.Controls.Add($button)

# Show the form
$form.ShowDialog()
