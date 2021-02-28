param (
    [Parameter(Mandatory = $true)]
    [string] $JsonFilePath
)

# The result CSV file create at the same location of $JsonFilePath.
$csvFilePath = Join-Path -Path ([IO.Path]::GetDirectoryName($JsonFilePath)) -ChildPath ([IO.Path]::GetFileNameWithoutExtension($JsonFilePath) + '.csv')

Get-Content -LiteralPath $JsonFilePath -Encoding utf8 -Raw |
    ConvertFrom-Json |
    ForEach-Object -Process {
        $question = $_

        # The final question has not a question ID. It is not a question actually, just the thanks message.
        if ($question.QuestionIDs.Length -ne 0) {
            $questionID = $question.QuestionIDs[0]
            $questionDefinition = $question.QuestionDefinitions.$questionID
            $dataExportTag = $questionDefinition.DataExportTag
            $questionAndChoiceInEnglish = $questionDefinition.Language.EN

            # Question text
            $questionText = $questionAndChoiceInEnglish.QuestionText.
                Replace('\r\n', "`n").
                Replace('\n', "`n").
                Replace('<br>', "`n").
                Replace('<i>', '').
                Replace('</i>', '')
            [PSCustomObject] @{
                QuestionID    = $questionID
                DataExportTag = $dataExportTag
                ContentRole   = 'Question'
                Content       = $questionText
            }

            $questionAndChoiceInEnglish.Choices |
                Get-Member -MemberType NoteProperty |
                Select-Object -Property 'Name' |
                ForEach-Object -Process {
                    $choiceNum = $_.Name

                    # Question choice
                    [PSCustomObject] @{
                        QuestionID    = $questionID
                        DataExportTag = $dataExportTag
                        ContentRole   = 'Choice {0}' -f $choiceNum
                        Content       = $questionAndChoiceInEnglish.Choices.$choiceNum.Display
                    }
                }
        }
    } |
    ConvertTo-Csv -Delimiter ',' -UseQuotes Always |
    Set-Content -LiteralPath $csvFilePath -Encoding utf8 -Force
