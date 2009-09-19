{-
  Copyright (C) 2009 John Millikin <jmillikin@gmail.com>
  
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
-}

module Tests.Names (nameTests) where

import Control.Monad (replicateM)
import Data.List (intercalate)
import Data.Maybe (fromJust, isJust, isNothing)
import Test.QuickCheck
import Test.QuickCheck.Batch (run)
import DBus.Types.ObjectPath

nameTests =
	[ run (prop_Equality :: ObjectPath -> Bool)
	, run prop_Identity
	, run prop_Invalid0
	, run prop_Invalid1
	, run prop_Invalid2
	, run prop_Invalid3
	]

prop_Equality x = x == x

prop_Identity x = mkObjectPath (strObjectPath x) == Just x

prop_Invalid0 = isNothing . mkObjectPath $ ""
prop_Invalid1 = isNothing . mkObjectPath $ "a"
prop_Invalid2 = isNothing . mkObjectPath $ "/a/"
prop_Invalid3 = isNothing . mkObjectPath $ "/a/-"

instance Arbitrary ObjectPath where
	arbitrary = do
		let chars = ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9'] ++ "_"
		let genElement = sized $ \n -> do
			n' <- choose (1, max 1 n)
			replicateM n' (elements chars)
		let genElements = sized $ \n -> do
			n' <- choose (1, max 1 n)
			replicateM n' genElement
		
		useRoot <- frequency [(1, return True), (9, return False)]
		path <- if useRoot
			then return "/"
			else fmap (intercalate "/" . ([] :)) genElements
		return . fromJust . mkObjectPath $ path