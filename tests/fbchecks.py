#!/usr/bin/env python
'Example for running fontbakery ttf tests'
__url__ = 'http://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2020 SIL International (http://www.sil.org)'
__license__ = 'Released under the MIT License (http://opensource.org/licenses/MIT)'
__author__ = 'David Raymond'

from silfont.fbtests.ttfchecks import exclude_list, make_profile, check, PASS, FAIL

#
# exclude_list is a list of all checks that will be removed from the standard list of check fontbakery runs
# This list cans be edited to override the standard exclusions
# See examples below
#

# To reinstate the copyright check (which is normally excluded), uncomment the following line
#exclude_list.remove("com.google.fonts/check/metadata/copyright")

# To prevent the hinting_impact check from running, uncomment the following line
#exclude_list.append("com.google.fonts/check/hinting_impact")

#
#  Create the fontbakery profile
#
profile = make_profile(exclude_list) # Use ...(exclude_list, variable_font=True) to include variable font tests

# Add any project-specific tests (This dummy test should normally be commented out!)

@profile.register_check
@check(
  id = 'org.sil.software/dummy',
  rationale = """
    There is no reason for this test!
    """
)
def org_sil_software_dummy():
  """Dummy test that always fails"""
  if True: yield FAIL, "Oops!"


'''
Run this using 

    $ fontbakery check-profile fbchecks.py <ttf file(s) to check> --html <name of file for html results>
eg
    $ fontbakery check-profile fbchecks.py results/*.ttf --html results/Andika-Mtihani-fontbakery-ttfcheck-report.html
    
Reducing screen output

  This may be desirable, since the html report still contains all the data
  
  -l FAIL will only log details of checks that fail.  (By default, WARN messages also go to screen)
  -l ERROR will reduce it further - ERRORs indicate a Font Bakery (or dependencies) problem rather than font problem
  
  -n will remove the progress bar
  
'''