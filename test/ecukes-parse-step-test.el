(ert-deftest parse-step-given ()
  (let ((step (ecukes-test-parse-feature-step "given.feature")))
    (should (equal "Given I see something on the screen" (ecukes-step-name step)))
    (should-be-regular-step step)))

(ert-deftest parse-step-when ()
  (let ((step (ecukes-test-parse-feature-step "when.feature")))
    (should (equal "When I see something on the screen" (ecukes-step-name step)))
    (should-be-regular-step step)))

(ert-deftest parse-step-then ()
  (let ((step (ecukes-test-parse-feature-step "then.feature")))
    (should (equal "Then I should see something on the screen" (ecukes-step-name step)))
    (should-be-regular-step step)))

(ert-deftest parse-step-and ()
  (let ((step (ecukes-test-parse-feature-step "and.feature")))
    (should (equal "And I see something else on the screen" (ecukes-step-name step)))
    (should-be-regular-step step)))

(ert-deftest parse-step-but ()
  (let ((step (ecukes-test-parse-feature-step "but.feature")))
    (should (equal "But I dont see something on the screen" (ecukes-step-name step)))
    (should-be-regular-step step)))

(ert-deftest parse-step-py-string-all-good ()
  (let* ((step (ecukes-test-parse-feature-step "py-string-all-good.feature"))
         (arg (ecukes-step-arg step))
         (split (split-string arg "\n")))
    (should (equal "Given this text:" (ecukes-step-name step)))
    (should (equal "Lorem ipsum dolor sit amet." (nth 0 split)))
    (should (equal "Curabitur pellentesque iaculis eros." (nth 1 split)))
    (should-be-py-string-step step)))

(ert-deftest parse-step-py-string-whitespace ()
  (let* ((step (ecukes-test-parse-feature-step "py-string-whitespace.feature"))
        (arg (ecukes-step-arg step))
        (split (split-string arg "\n")))
    (should (equal "Given this text:" (ecukes-step-name step)))
    (should (equal "Lorem ipsum dolor sit amet." (nth 0 split)))
    (should (equal "" (nth 1 split)))
    (should (equal "In congue. Curabitur pellentesque iaculis eros." (nth 2 split)))
    (should-be-py-string-step step)))

(ert-deftest parse-step-py-string-wrong-indentation ()
  (let* ((step (ecukes-test-parse-feature-step "py-string-wrong-indentation.feature"))
         (arg (ecukes-step-arg step))
         (split (split-string arg "\n")))
    (should (equal "Given this text:" (ecukes-step-name step)))
    (should (equal "Lorem ipsum dolor sit amet." (nth 0 split)))
    (should (equal "       Curabitur pellentesque iaculis eros." (nth 1 split)))
    (should-be-py-string-step step)))

(ert-deftest parse-step-table-all-good ()
  (let* ((step (ecukes-test-parse-feature-step "table-all-good.feature"))
         (table (ecukes-step-arg step))
         (header (ecukes-table-header table))
         (rows (ecukes-table-rows table)))
    (should (equal "Given these meals:" (ecukes-step-name step)))
    (let ((hamburger (nth 0 rows))
          (pizza (nth 1 rows)))
      (should (equal "meal" (nth 0 header)))
      (should (equal "price" (nth 1 header)))
      (should (equal "Hamburger" (nth 0 hamburger)))
      (should (equal "$4.50" (nth 1 hamburger)))
      (should (equal "Pizza" (nth 0 pizza)))
      (should (equal "$5.30" (nth 1 pizza)))
      (should-be-table-step step))))

(ert-deftest parse-step-table-wrong-indentation ()
  (let* ((step (ecukes-test-parse-feature-step "table-wrong-indentation.feature"))
         (table (ecukes-step-arg step))
         (header (ecukes-table-header table))
         (rows (ecukes-table-rows table)))
    (should (equal "Given these meals:" (ecukes-step-name step)))
    (let ((hamburger (nth 0 rows))
          (pizza (nth 1 rows)))
      (should (equal "meal" (nth 0 header)))
      (should (equal "price" (nth 1 header)))
      (should (equal "Hamburger" (nth 0 hamburger)))
      (should (equal "$4.50" (nth 1 hamburger)))
      (should (equal "Pizza" (nth 0 pizza)))
      (should (equal "$5.30" (nth 1 pizza)))
      (should-be-table-step step))))

(ert-deftest parse-step-table-row-all-good ()
  (let* ((row "| first | second | third |")
         (list (ecukes-parse-table-row row)))
    (should (equal "first" (nth 0 list)))
    (should (equal "second" (nth 1 list)))
    (should (equal "third" (nth 2 list)))))

(ert-deftest parse-step-table-row-whitespace ()
  (let* ((row "    |     first |    second     | third |    ")
         (list (ecukes-parse-table-row row)))
    (should (equal "first" (nth 0 list)))
    (should (equal "second" (nth 1 list)))
    (should (equal "third" (nth 2 list)))))

(defun should-be-regular-step (step)
  (should-be-type step 'regular))

(defun should-be-py-string-step (step)
  (should-be-type step 'py-string))

(defun should-be-table-step (step)
  (should-be-type step 'table))

(defun should-be-type (step type)
  (should (equal type (ecukes-step-type step))))
