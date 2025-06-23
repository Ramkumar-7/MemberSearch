



function printMessage($elements, getMessage, $output) {
    filled($elements).each(function() {
        var $input = $(this);
        var result = getMessage($input);
        $output.html(result === true ? "" : result);
    });
}

function errorValidation($elements, isValid, clientMessage) {
    valid = true;
    $elements.each(function() {
        $input = $(this);
        var status = isValid($input);
        if (status != true) {
            clientMessage = clientMessage || status;
            $input.popMessage(clientMessage);
            valid = false;
            return false;
        }
    });
    return valid;
}

function regexpValidation($elements, regexp, message) {
    return errorValidation(
        $elements,
        function($input) {
            return regexp.test($input.val());
        },
        message
    );
}

function checkOneRequired($elements, message) {
    valid = false;
    $elements.each(function() {
        $input = $(this);
        if ($input.val().trim() != "") {
            valid = true;
            return false;
        }
    });

    if (!valid && $elements.length > 0) {
        $elements.eq(0).popMessage(message);
    }
    return valid;
}
function checkOneSelectRequired($elements, message) {
    valid = false;
    $elements.each(function() {
        $input = $(this).find("option:selected");
       
        if ($input.val() != "") {
            valid = true;
            return false;
        }
    });

    if (!valid && $elements.length > 0) {
        $elements.eq(0).popMessage(message);
    }
    return valid;
}
function checkOneSetRequired(elementsArray, message) {
    if (elementsArray.length == 0) {
        return true;
    }
    for (var i = 0; i < elementsArray.length; ++i) {
        $elements = elementsArray[i];
        var setValid = true;
        $elements.each(function() {
            $input = $(this);
            if ($input.val().trim() == "") {
                setValid = false;
                return false;
            }
        });
        if (setValid) {
            return true;
        }
    }
    elementsArray[0].eq(0).popMessage(message);
    return false;
}

function checkQuestions($elements) {
    var used = {};
    var duplicate = false;

    for (i = 0; i < $elements.size(); i++) {
        var selected = $elements[i];
        var value = selected.tagName == "DIV" ? $.trim(selected.innerHTML) : selected.value.trim() ;
        if (used[value]) {
            duplicate = $elements.eq(i)
            break;
        }
        used[value] = $elements.eq(i)
    }

    if (duplicate) {
        if(!duplicate.is(':enabled') && used[duplicate.get(0).value].is(':enabled')){
            duplicate = used[duplicate.get(0).value];
        }
        if (duplicate.prop("tagName") == "OPTION") {
            duplicate = duplicate.parent();
        }
        duplicate.popMessage("Please pick a unique question");
        return false;
    }

    return true;
}

function checkMatch($elements, message) {
    if ($elements.length == 0) {
        return true;
    }

    var valid = true;
    var sample = $elements.eq(0).val();
    $elements.each(function() {
        $input = $(this);
        if ($input.val() != sample) {
            $input.popMessage(message);
            valid = false;
            return false;
        }
    });

    return valid;
}

function filled($elements) {
    return $elements.filter(function() {
        return this.value.trim() != "";
    });
}

function checkRequired($elements) {
    return errorValidation(
        $elements,
        function ($input) {
            var val = $input.val();
            return val && !/^\s*$/m.test(val);
        },
        "Please fill out this field"
    );
}

function checkRequiredWithErrorMessage($elements,message) {
    return errorValidation(
        $elements,
        function ($input) {
            var val = $input.val();
            return val && !/^\s*$/m.test(val);
        },
        message
    );
}

function checkRequiredWhenEntering($required, $entering) {
    var enteringFilled = false;
    $entering.each(function() {
        var $element = $(this);
        if ($element.val().trim().length != 0) {
            enteringFilled = true;
            return false;
        }
    });
    if (enteringFilled) {
        return checkRequired($required);
    }
    return true;
}


function checkZip($elements) {
    return regexpValidation(
        filled($elements),
        /(^\d{5}$)|(^\d{5}\-\d{4}$)|(^\d{9}$)/,
        "Please enter correct zip (XXXXX or XXXXX-YYYY)"
    );
}

function treatmentcheckZip($elements) {
    return regexpValidation(
        filled($elements),
        /(^\d{5}$)|(^\d{5}\d{4}$)|(^\d{9}$)/,
        "Please enter correct zip (XXXXX or XXXXXYYYY)"
    );
}

function checkSSN($elements) {
    return regexpValidation(
        filled($elements),
        /^\d{3}-?\d{2}-?\d{4}$/,
        "Please enter correct ssn (XXX-XX-XXXX)"
    );
}

function checkState($elements) {
    return regexpValidation(
        filled($elements),
        /^[A-Za-z]{2}$/,
        "State abbreviation should be exactly 2 letters"
    );
}

function checkEmail($elements) {
    return regexpValidation(
        filled($elements),
        /\S+@\S+\.\S+/,
        "Email is incorrect"
    );
}

function checkDates($elements) {
    return errorValidation(
        filled($elements),
        function($input) {
            try {
                var currVal = $input.val();
                var rxDatePattern = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)(\d{4})$/;
                var dtArray = currVal.match(rxDatePattern);
                if (dtArray == null) {
                    return false;
                }
                var dtMonth = dtArray[1];
                var dtDay = dtArray[3];
                var dtYear = dtArray[5];
                var isOK = true;
                if (dtMonth < 1 || dtMonth > 12)
                    return false;
                else if (dtDay < 1 || dtDay > 31)
                    return false;
                else if ((dtMonth == 4 || dtMonth == 6 || dtMonth == 9 || dtMonth == 11) && dtDay == 31)
                    return false;
                else if (dtMonth == 2) {
                    var isleap = (dtYear % 4 == 0 && (dtYear % 100 != 0 || dtYear % 400 == 0));
                    if (dtDay > 29 || (dtDay == 29 && !isleap)) {
                        return false;
                    }
                }
                return true;
            }
            catch (e) {
                return false;
            }
        },
        "Date format is incorrect"
    );
}

function checkDateOrder($elements){
    dpg = $.fn.datepicker.DPGlobal;
    var from = dpg.parseDate( $elements.eq(0).val(),dpg.parseFormat("mm/dd/yyyy"));
    var to = dpg.parseDate( $elements.eq(1).val(),dpg.parseFormat("mm/dd/yyyy"));
    if(from>to){
        $elements.eq(1).popMessage("The to date must be greater than or equal to the from date");
        return false;
    }else{
        return true;
    }
}

//should be used on search forms
function checkRequiredFromToDates($elements){
    return checkRequired($elements) && checkDates($elements) && checkDateOrder($elements);
}

function checkPasswordLength($input) {
    return $input.val().trim().length >= 8;
}

function checkPasswordRestriction($input) {
    return /^((?![ &\'"<>\\/`]).)*$/.test($input.val());
}

function checkPasswordVariety($input) {
    var pass = $input.val().trim();
    var variety = 0;
    if (/[a-z]/.test(pass)) {
        ++variety;
    }
    if (/[A-Z]/.test(pass)) {
        ++variety;
    }
    if (/[0-9]/.test(pass)) {
        ++variety;
    }
    if (/[*%~!@#$^( )+\-=\[\]{};:,.?|_]/.test(pass)) {
        ++variety;
    }
    return variety >= 3;
}

function getPasswordErrorMessage($input) {
    var lengthMessage = "The password is too short";
    var restrictionMessage = "You can not use spaces and following characters: &\'<>\"\\/`";
    var varietyMessage = "Add lowercase, uppercase, numbers and special characters";
    if (!checkPasswordRestriction($input)) {
        $(".pwstrength_viewport_progress").hide();
        return restrictionMessage;
    } else {
        $(".pwstrength_viewport_progress").show();
    }
    if (!checkPasswordLength($input)) {
        return lengthMessage;
    }
    if (!checkPasswordVariety($input)) {
        return varietyMessage;
    }
    return true;
}

function checkPasswordPolicy($elements) {
    return errorValidation(filled($elements), getPasswordErrorMessage);
}

function checkPasswordConfirm($elements) {
    return checkMatch($elements,
        "Passwords do not match "
    );
}

function checkCurrency($elements){
        return regexpValidation(
        filled($elements),
        /^[0-9]*(\.[0-9]+)?$/,
         "Please enter correct cash amount  "

    );
}

function checkNdcCode($element){
        return regexpValidation(
        filled($element),
        /^[\d]{10,11}$/,
         "Invalid NDC Code!"

    );
}

function checkNumber($element){
        return regexpValidation(
        filled($element),
        /^\d+$/,
         "Entered value is not a number"

    );
}

function verifyConfirmPass()
{
	if(!checkMatch($("#newPass, #verifPass")))
	{
		document.getElementById("confirmPolicy").innerHTML ="Passwords do not match ";
	}
	else
	{
		document.getElementById("confirmPolicy").innerHTML =""
	}
}



